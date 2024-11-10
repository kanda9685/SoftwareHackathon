import os
import base64
import time
import asyncio
from io import BytesIO
from PIL import Image
from openai import OpenAI
from pydantic import BaseModel

CHATGPT_API_KEY = "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"
client = OpenAI(api_key=CHATGPT_API_KEY)

# 画像生成関数（バックエンドで画像生成し、フロントエンドに直接送信）
async def generate_image_base64(prompt: str) -> str:
    response = client.images.generate(
        model="dall-e-3",
        prompt=prompt,
        n=1,
        size="1024x1024",
        response_format="b64_json"
    )

    # レスポンスからBase64エンコードされた画像データを取得
    image_data_base64 = response.data[0].b64_json  # 正しいアクセス方法
    return image_data_base64

# 画像生成
async def generate_image(menu_name):
    prompt = f"A simple and realistic photo of {menu_name} taken in a casual restaurant setting. \
The {menu_name} is placed on a clean table or surface, with natural lighting, emphasizing its natural textures and colors. "

    start_time = time.time()
    image_data_base64 = await generate_image_base64(prompt)
    elapsed_time = time.time() - start_time

    return {
        "image_base64": image_data_base64,
        "elapsed_time": elapsed_time
    }

# テストコード（FastAPIとは別でローカルでテストするため）
if __name__ == "__main__":
    menu_name = "寿司"  # 任意のメニュー名

    # 画像生成処理
    async def test_generate_image():
        image_data_base64 = await generate_image(menu_name)

        # Base64データを画像にデコードして表示
        image_data = base64.b64decode(image_data_base64["image_base64"])
        image = Image.open(BytesIO(image_data))
        image.show()  # PILで画像を表示

    asyncio.run(test_generate_image())  # 非同期でテスト関数を実行