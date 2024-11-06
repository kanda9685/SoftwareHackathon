import logging
import asyncio
import aiohttp
from io import BytesIO
from PIL import Image
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from backend.utils.config import GOOGLE_SEARCH_API_KEY, CSE_ID
import time

# ログの設定
logging.basicConfig(level=logging.INFO)

def get_service():
    """Google Custom Search APIのサービスを初期化して返す。"""
    return build("customsearch", "v1", developerKey=GOOGLE_SEARCH_API_KEY)

async def search_image_url(service, query):
    """指定されたクエリで画像を非同期で1枚だけ検索し、画像のURLを返す。

    Args:
        service: Google Custom Search APIのサービスオブジェクト。
        query (str): 検索するキーワード。

    Returns:
        str: 取得した画像のURL。
    """
    try:
        search_response = await asyncio.to_thread(
            service.cse().list,
            q=query,
            cx=CSE_ID,
            lr='lang_ja',
            searchType='image',
            rights='cc_publicdomain',  # パブリックドメインの画像のみ
            num=1  # 1枚のみ取得
        )
        search_response = search_response.execute()
        print(search_response)
        
        # 画像URLの取得
        items = search_response.get('items', [])
        if items:
            return items[0]['link']  # 最初の画像のURLを返す
        else:
            logging.warning("No images found for the query.")
            return None
    except HttpError as e:
        logging.error("An error occurred: %s", e)
        return None

async def get_image(menu: str) -> Image:
    """指定されたクエリで画像を検索し、取得した画像を返す。

    Args:
        query (str): 検索するキーワード。

    Returns:
        Image: 取得した画像のPIL Imageオブジェクト。
    """
    service = get_service()
    
    query = f"{menu}"
    
    # 画像URLを検索
    image_url = await search_image_url(service, query)
    
    if image_url:
        return image_url
    else:
        logging.error("No image URL found.")
        return ""

# 使用例
if __name__ == "__main__":
    search_query = 'ラーメン'  # 検索するキーワード
    start_time = time.time()
    image_url = asyncio.run(get_image(search_query))
    print("実行時間：", time.time() - start_time)
    # 画像を表示
    if image_url:
        print(image_url)
    else:
        print("Image could not be retrieved.")
