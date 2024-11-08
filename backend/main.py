import base64
import logging
from fastapi import FastAPI, File, UploadFile, HTTPException, Request, Form, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from typing import List, Dict, Any, Optional
from PIL import Image
from io import BytesIO
from backend.modules.ocr import get_menus
from backend.modules.image_search import get_image
from backend.modules.menu_description import transcribe_and_describe
import time, os, requests
from fastapi.responses import JSONResponse
from pathlib import Path
import asyncio
from urllib.parse import unquote
import math

app = FastAPI()

MAIN_URL = "http://172.16.0.178:8000"

# CORSの設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 必要に応じて制限
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/process_menus", response_model=Dict[str, Any])
async def process_menus_endpoint(file: UploadFile = File(...), language: str = "english"):
    """
    画像を処理してメニュー項目を抽出し、画像と説明文を生成するエンドポイント。

    Args:
        file (UploadFile): アップロードされた画像ファイル。

    Returns:
        dict: 抽出されたメニュー項目、画像データと説明文を含む辞書。
    """
    try:
        # アップロードされた画像ファイルをPIL Imageオブジェクトとして読み込み
        image = Image.open(file.file)

        # OCR処理を非同期で実行してメニュー項目を抽出
        menu_items = await get_menus(image)
        print(language)

        results = []
        start_time = time.time()
        
        # メニュー項目を処理
        items = await transcribe_and_describe(menu_items, language)

        # 各メニュー項目の画像を並列で非同期に取得
        image_tasks = [
            get_image(item['Menu_jp']) for item in items
        ]

        # 並列に画像を取得
        image_urls = await asyncio.gather(*image_tasks)

        # 取得した画像URLと他の情報を組み合わせて結果を生成
        for i, item in enumerate(items):
            image_url = image_urls[i]  # 非同期で取得した画像URL
            
            image_urls_list = []
            image_url2 = f"{MAIN_URL}/uploaded_images/{item['Menu_jp']}/{item['Menu_jp']}_1.jpg"
            image_url3 = f"{MAIN_URL}/uploaded_images/{item['Menu_jp']}/{item['Menu_jp']}_2.jpg"
            image_url4 = f"{MAIN_URL}/uploaded_images/{item['Menu_jp']}/{item['Menu_jp']}_3.jpg"
            image_urls_list.append(image_url)
            image_urls_list.append(image_url2)
            image_urls_list.append(image_url3)
            image_urls_list.append(image_url4)
            
            # 結果に追加
            results.append({
                "menu_item": item['Menu_jp'],
                "menu_en": item['Menu_en'],
                "description": item['Description'],
                "image_urls": image_urls_list
            })
        
        return {"results": results, "time": time.time() - start_time}

    except Exception as e:
        logging.error("Error in processing image: %s", e)
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/translate_menus", response_model=Dict[str, Any])
async def translate_menus_endpoint(request: Request):
    """
    メニュー項目を指定した言語に翻訳するエンドポイント。

    Args:
        menu_items (List[Dict[str, str]]): メニュー項目のリスト（日本語）。
        language (str): 翻訳対象の言語。

    Returns:
        dict: 翻訳されたメニュー項目を含む辞書。
    """
    try:
        
        # デコードされたリクエストデータを確認
        data = await request.json()
        print("Received data:", data)
    
        # データを取得
        menu_items = data.get("menu_items")
        language = data.get("language")
        
        results = []
        translated_items = await transcribe_and_describe(menu_items, language)
        
        for item in translated_items:
            # 各メニュー項目に対して翻訳と説明を追加
            results.append({
                "menu_item": item['Menu_jp'],
                "menu_en": item['Menu_en'],
                "description": item['Description']
            })
            
        return JSONResponse(content={"results": results}, media_type="application/json; charset=UTF-8")

    except Exception as e:
        logging.error("Error in translation: %s", e)
        raise HTTPException(status_code=500, detail=str(e))

# 画像ファイルが保存されているディレクトリ（要変更）
IMAGE_DIRECTORY = "C:\\Users\\meron\\Desktop\\SoftwareHackathon\\backend\\uploaded_images"

# image_name=旬の魚のカルパッチョ
@app.get("/uploaded_images/{folder_name}/{image_name}")
async def get_localimage(image_name: str, folder_name: str, shop_name: str):

    image_path = os.path.join(IMAGE_DIRECTORY,shop_name,folder_name,image_name)

    if os.path.exists(image_path):
        return FileResponse(image_path)
    return ""

@app.post("/image_upload")
async def upload_image(file: UploadFile = File(...), file_name: str = Form(...)):
    try:
        # 似た名前のフォルダを探す
        similar_folders = [f for f in os.listdir(IMAGE_DIRECTORY) if file_name in f]
        if similar_folders:
            # 既存の似たフォルダに保存
            target_folder = os.path.join(IMAGE_DIRECTORY, similar_folders[0])
        else:
            # 新しいフォルダを作成
            target_folder = os.path.join(IMAGE_DIRECTORY, file_name)
            Path(target_folder).mkdir(parents=True, exist_ok=True)
        
        # ファイル名が重複しないように連番を付与
        counter = 1
        save_path = os.path.join(target_folder, f"{file_name}_{counter}.jpg")
        while os.path.exists(save_path):
            counter += 1
            save_path = os.path.join(target_folder, f"{file_name}_{counter}.jpg")

        # アップロードされたファイルを開いて保存
        with open(save_path, "wb") as buffer:
            buffer.write(await file.read())

    except Exception as e:
        logging.error("Error in uploading image: %s", e)
        raise HTTPException(status_code=500, detail=str(e))

# Google Maps APIのURLとAPIキーを設定
GOOGLE_MAPS_API_KEY = "AIzaSyDpAo2dH8sFpPdcyhObO02txOgXOJGvqoA"
GOOGLE_MAPS_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"


# ハーサイン距離計算用の関数
def haversine(lat1, lon1, lat2, lon2):
    """
    ハーサイン距離計算
    :param lat1, lon1: 出発地点の緯度・経度
    :param lat2, lon2: 目的地の緯度・経度
    :return: 2地点間の距離（メートル単位）
    """
    # 地球の半径 (メートル)
    R = 6371000

    # 緯度と経度をラジアンに変換
    lat1 = math.radians(lat1)
    lon1 = math.radians(lon1)
    lat2 = math.radians(lat2)
    lon2 = math.radians(lon2)

    # ハーサイン距離の計算
    dlat = lat2 - lat1
    dlng = lon2 - lon1
    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # 距離をメートルで返す
    return R * c

@app.get("/nearby_restaurants/")
async def get_nearby_restaurants(lat: float, lng: float, radius: int = 10, type: str = "restaurant") -> dict:
    """
    最寄りの飲食店を取得するAPI
    :param lat: 端末の緯度
    :param lng: 端末の経度
    :param radius: 検索半径 (メートル単位)
    :param type: 検索する施設の種類。デフォルトは"restaurant"
    :return: 緯度と経度の絶対値距離が最小の飲食店
    """
    # Google Maps APIのリクエストパラメータ
    params = {
        "location": f"{lat},{lng}",
        "radius": radius,
        "type": type,
        "key": GOOGLE_MAPS_API_KEY,
    }

    # Google Maps APIを呼び出し
    response = requests.get(GOOGLE_MAPS_API_URL, params=params)

    # レスポンスが正常でない場合はエラーメッセージを返す
    if response.status_code != 200:
        return {"error": "Failed to fetch data from Google Maps API"}

    # 結果をJSON形式で取得
    results = response.json().get("results", [])
    
    # 最寄りの飲食店を探す
    nearest_restaurant = None
    min_distance = float('inf')  # 最小距離（初期値は無限大）

    for restaurant in results:
        # 飲食店の緯度・経度を取得
        rest_lat = restaurant["geometry"]["location"]["lat"]
        rest_lng = restaurant["geometry"]["location"]["lng"]

        # 端末から飲食店までの距離を計算
        distance = haversine(lat, lng, rest_lat, rest_lng)

        # 最小距離を更新
        if distance < min_distance:
            min_distance = distance
            nearest_restaurant = {
                "name": restaurant["name"],
                "lat": rest_lat,
                "lng": rest_lng,
                "distance": min_distance
            }

    # 最寄りの飲食店が見つからなかった場合のエラーハンドリング
    if not nearest_restaurant:
        return "error"

    return nearest_restaurant["name"]