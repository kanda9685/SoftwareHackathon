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
from backend.modules.dall_e import generate_image
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

logging.basicConfig(level=logging.ERROR, encoding="utf-8")
import sys
sys.stdout.reconfigure(encoding='utf-8')


@app.post("/process_menus", response_model=Dict[str, Any])
async def process_menus_endpoint(lat: str=Form(...), lng: str=Form(...), file: UploadFile = File(...), language: str = Form(...)):
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

        lat = float(lat)
        lng = float(lng)
        shop_name = get_nearby_restaurants(lat,lng)
    
        # 取得した画像URLと他の情報を組み合わせて結果を生成
        for i, item in enumerate(items):
            image_url = image_urls[i]  # 非同期で取得した画像URL
            
            image_urls_list = []
            # image_url2 = f"{MAIN_URL}/uploaded_images/menu1/{item['Menu_jp']}/{item['Menu_jp']}_1.jpg"
            # image_url3 = f"{MAIN_URL}/uploaded_images/menu1/{item['Menu_jp']}/{item['Menu_jp']}_2.jpg"
            # image_url4 = f"{MAIN_URL}/uploaded_images/menu1/{item['Menu_jp']}/{item['Menu_jp']}_3.jpg"
            image_urls_list.append(image_url)
            # image_urls_list.append(image_url2)
            # image_urls_list.append(image_url3)
            # image_urls_list.append(image_url4)
            
            # 結果に追加
            results.append({
                "menu_item": item['Menu_jp'],
                "menu_en": item['Menu_en'],
                "description": item['Description'],
                "image_urls": image_urls_list,
                'shop_name':shop_name
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
    
# API エンドポイントの作成
@app.post("/generate-image", response_model=Dict[str, str])
async def generate_image_endpoint(request: Request):
    # デコードされたリクエストデータを確認
    data = await request.json()
    # データを取得
    menu_name = data.get("menu_name")

    # 画像を生成
    image_data_base64 = await generate_image(menu_name)

    return {
        "image_base64": image_data_base64["image_base64"]
    }


# 画像ファイルが保存されているディレクトリ（要変更）
IMAGE_DIRECTORY = "C:\\Users\\meron\\Desktop\\SoftwareHackathon\\backend\\uploaded_images"


@app.get("/uploaded_images/{shop_name}/{folder_name}/{image_name}")
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

def get_nearby_restaurants(lat: float, lng: float):

    # Google Maps APIのURLとAPIキーを設定
    GOOGLE_MAPS_API_KEY = "AIzaSyDpAo2dH8sFpPdcyhObO02txOgXOJGvqoA"
    GOOGLE_MAPS_API_URL = "https://places.googleapis.com/v1/places:searchNearby"

    # ヘッダーの設定
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": GOOGLE_MAPS_API_KEY,  # ここに実際のAPIキーを挿入
        "X-Goog-FieldMask": "places.displayName"
    }

    # リクエストデータ（JSON形式）
    data = {
        "includedTypes": ["restaurant"],
        "maxResultCount": 10,
        "languageCode" : "ja",
        "rankPreference" : "DISTANCE",
        "locationRestriction": {
            "circle": {
                "center": {
                    "latitude": lat,
                    "longitude": lng
                },
                "radius": 100.0
            }
        }
    }

    # POSTリクエストを送信
    response = requests.post(GOOGLE_MAPS_API_URL, headers=headers, json=data)

    # レスポンスが正常でない場合はエラーメッセージを返す
    if response.status_code != 200:
        return "error"

    response=response.json()
    nearest_restaurant = response["places"][0]["displayName"]["text"]
    
    print(nearest_restaurant)
    return nearest_restaurant