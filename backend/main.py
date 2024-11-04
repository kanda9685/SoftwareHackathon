import base64
import logging
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import Dict, Any
from PIL import Image
from io import BytesIO
from backend.modules.ocr import get_menus
from backend.modules.image_search import get_image
from backend.modules.menu_description import transcribe_and_describe

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
async def process_menus_endpoint(file: UploadFile = File(...)):
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

        results = []
        for item in menu_items:
            # 各メニュー項目に対し、画像検索と説明文生成を非同期で実行
            image_obj = await get_image(item)  
            translation, description = await transcribe_and_describe(item)  

            if image_obj:
                # 画像をRGBに変換（必要な場合）
                if image_obj.mode == 'RGBA':
                    image_obj = image_obj.convert('RGB')  # Convert to RGB

                # 画像をbase64でエンコードして文字列として返す
                buffered = BytesIO()
                image_obj.save(buffered, format="JPEG")
                encoded_image = base64.b64encode(buffered.getvalue()).decode("utf-8")
            else:
                encoded_image = None

            results.append({
                "menu_item": item,
                # "image": encoded_image,  # 画像のbase64エンコード
                "menu_en": translation,
                "description": description
            })

        return {"results": results}

    except Exception as e:
        logging.error("Error in processing image: %s", e)
        raise HTTPException(status_code=500, detail=str(e))
