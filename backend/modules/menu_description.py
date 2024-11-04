import os
import asyncio
from openai import OpenAI
from backend.utils.config import CHATGPT_API_KEY

# OpenAIクライアントの初期化
client = OpenAI(api_key=CHATGPT_API_KEY)

async def transcribe_and_describe(dish_name: str) -> tuple[str, str]:
    """
    日本語の料理名を英語に翻訳し、簡単な説明を提供します。

    Args:
        dish_name (str): 料理名（日本語）。

    Returns:
        tuple[str, str]: 英語の翻訳と説明文を含むタプル。
    """
    # プロンプトを作成
    prompt = (
        f'Translate the following Japanese dish name to English and provide a brief description. '
        f'Return the translation and description as two separate strings, separated by a vertical bar (|). '
        f'For example, "いちごのパフェ" is "strawberry parfait" | "a parfait made with strawberries and cream." '
        f'Now, for "{dish_name}":'
    )

    try:
        # チャットコンプリーションのリクエストを非同期で行う
        chat_completion = await asyncio.to_thread(client.chat.completions.create,
            messages=[{"role": "user", "content": prompt}],
            model="gpt-4o-mini",
        )

        # レスポンスの取得
        response_content = chat_completion.choices[0].message.content.strip()
        print(response_content)
        # 翻訳と説明文の二つの値を返す
        translation, description = response_content.split("|")
        return translation.strip(), description.strip()

    except Exception as e:
        print(f"An error occurred: {e}")
        return "", ""

# 使用例
if __name__ == "__main__":
    dish = "パンプキンパイ"
    translation, description = asyncio.run(transcribe_and_describe(dish))
    print(f"Translation: {translation}\nDescription: {description}")
