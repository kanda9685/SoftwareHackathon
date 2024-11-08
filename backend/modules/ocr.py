from pydantic import BaseModel
from PIL import Image
import pytesseract
import re
from typing import List
import asyncio

async def ocr_tesseract(image: Image) -> str:
    """OCRを使用して画像からテキストを抽出する。

    Args:
        image (Image): 処理するPIL Imageオブジェクト。

    Returns:
        str: 抽出されたテキスト。
    """
    # OCR処理を非同期で実行
    ocr_text = await asyncio.to_thread(pytesseract.image_to_string, image, lang='jpn+eng')
    return ocr_text.strip()

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
    ocr_text = await ocr_tesseract(image)
    # 得られた文字列をリストに分割
    text_list = await split_text_into_list(ocr_text)
    return text_list

# 使用例
if __name__ == "__main__":
    image_path = "images/menu_images/menu1.png" 
    image = Image.open(image_path)
    menu_items = asyncio.run(get_menus(image))
    
    # 結果を表示
    print("Extracted Menu Items:")
    for item in menu_items:
        print(f"- {item}")