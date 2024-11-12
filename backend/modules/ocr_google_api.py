from google.cloud import vision
from google.oauth2 import service_account
from PIL import Image
import io
import re
from typing import List
import asyncio

# Google Cloud Vision用のクライアントを作成
credentials = service_account.Credentials.from_service_account_file(
    '/Users/kandayuuto/Downloads/hip-gecko-440507-m8-fa1d5a368247.json'
)
client = vision.ImageAnnotatorClient(credentials=credentials)

async def ocr_google_cloud_vision(image: Image) -> str:
    """Google Cloud Visionを使用して画像からテキストを抽出する。

    Args:
        image (Image): 処理するPIL Imageオブジェクト。

    Returns:
        str: 抽出されたテキスト。
    """
    # 画像をバイト配列に変換
    with io.BytesIO() as output:
        image.save(output, format="PNG")
        content = output.getvalue()
    
    # Google Cloud Vision APIに画像データを送信
    image = vision.Image(content=content)
    response = await asyncio.to_thread(client.text_detection, image=image)
    
    # OCRの結果を取得
    if response.error.message:
        raise Exception(f"Google Cloud Vision API error: {response.error.message}")
    
    return response.full_text_annotation.text.strip()

async def split_text_into_list(text: str) -> List[str]:
    """テキストを改行または二つ以上の空白で分割し、リストに変換する。

    Args:
        text (str): 分割する文字列。

    Returns:
        List[str]: 分割された文字列のリスト。
    """
    text_list = re.split(r'\n|\s{2,}', text)  # 改行または二つ以上の空白で分割
    return [item for item in text_list if item]  # 空の文字列を除外

async def get_menus(image: Image) -> List[str]:
    """画像を処理して有効なメニュー項目を抽出する。

    Args:
        image (Image): 処理するPIL Imageオブジェクト。

    Returns:
        List[str]: 有効なメニュー項目のリスト。
    """
    # OCRを実行
    ocr_text = await ocr_google_cloud_vision(image)
    # 得られた文字列をリストに分割
    text_list = await split_text_into_list(ocr_text)
    return text_list

# 使用例
if __name__ == "__main__":
    image_path = "images/menu_images/menu2.png" 
    image = Image.open(image_path)
    menu_items = asyncio.run(get_menus(image))
    
    # 結果を表示
    print("Extracted Menu Items:")
    for item in menu_items:
        print(f"- {item}")
