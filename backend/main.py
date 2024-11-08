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
        # print(menu_items)

        results = []
        
        start_time = time.time()
        
        items = await transcribe_and_describe(menu_items, language)
        # print(items)

        for item in items:
            
            # 各メニュー項目に対し、画像検索と説明文生成を非同期で実行
            image_urls = []
            image_url = await get_image(item['Menu_jp'])  
            # 同じ画像を3枚掲載
            image_urls.append(image_url)
            image_urls.append('http://172.16.0.178:8000/uploaded_images/uma.jpg')
            image_urls.append('http://172.16.0.178:8000/uploaded_images/uma.jpg')
            
            # 各メニュー項目に対して翻訳と説明を追加
            results.append({
                "menu_item": item['Menu_jp'],
                "menu_en": item['Menu_en'],
                "description": item['Description'],
                "image_urls": image_urls
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

@app.get("/uploaded_images/{image_name}")
async def get_image(image_name: str):
    image_path = os.path.join(IMAGE_DIRECTORY, image_name)
    if os.path.exists(image_path):
        return FileResponse(image_path)
    return ""

@app.post("/image_upload")
async def upload_image(file: UploadFile = File(...), file_name: str = Form(...)):
    try:
        # ファイルを保存するパスを設定
        save_path = os.path.join(IMAGE_DIRECTORY, file_name)
        print(save_path)
        # アップロードされたファイルを開いて保存
        with open(save_path, "wb") as buffer:
            buffer.write(await file.read())

    except Exception as e:
        logging.error("Error in uploading image: %s", e)
        raise HTTPException(status_code=500, detail=str(e))
