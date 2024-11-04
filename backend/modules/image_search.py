import logging
import asyncio
import aiohttp
from io import BytesIO
from PIL import Image
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from backend.utils.config import GOOGLE_SEARCH_API_KEY, CSE_ID

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

async def download_image(url):
    """画像のURLから画像を非同期でダウンロードしてPIL Imageオブジェクトを返す。

    Args:
        url (str): ダウンロードする画像のURL。

    Returns:
        Image: ダウンロードした画像のPIL Imageオブジェクト。
    """
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            if response.status == 200:
                image_data = await response.read()
                return Image.open(BytesIO(image_data))
            else:
                logging.error("Failed to download image, status code: %d", response.status)
                return None

async def get_image(menu: str) -> Image:
    """指定されたクエリで画像を検索し、取得した画像を返す。

    Args:
        query (str): 検索するキーワード。

    Returns:
        Image: 取得した画像のPIL Imageオブジェクト。
    """
    service = get_service()
    
    query = f"{menu} 写真"
    
    # 画像URLを検索
    image_url = await search_image_url(service, query)
    
    if image_url:
        # 画像をダウンロード
        image = await download_image(image_url)
        return image
    else:
        logging.error("No image URL found.")
        return None

# 使用例
if __name__ == "__main__":
    search_query = 'パンプキンパイ'  # 検索するキーワード
    image = asyncio.run(get_image(search_query))
    
    # 画像を表示
    if image:
        image.show()
    else:
        print("Image could not be retrieved.")
