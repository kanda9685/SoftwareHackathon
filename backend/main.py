import base64
import logging
from fastapi import FastAPI, File, UploadFile, HTTPException, Request, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from typing import List, Dict, Any
from PIL import Image
from io import BytesIO
from backend.modules.ocr import get_menus
from backend.modules.image_search import get_image
from backend.modules.menu_description import transcribe_and_describe
import time, os
from fastapi.responses import JSONResponse
from pathlib import Path
import asyncio

app = FastAPI()

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
            # 同じ画像を3枚掲載（例）
            image_urls_list = [image_url, 'http://172.16.0.178:8000/uploaded_images/uma.jpg', 'http://172.16.0.178:8000/uploaded_images/uma.jpg']
            
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

# 画像ファイルが保存されているディレクトリ（要変更）
IMAGE_DIRECTORY = "C:\\Users\\meron\\Desktop\\SoftwareHackathon\\backend\\uploaded_images"

@app.get("/uploaded_images/{image_name}")
async def get_localimage(image_name: str):
    image_path = os.path.join(IMAGE_DIRECTORY, image_name)
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
