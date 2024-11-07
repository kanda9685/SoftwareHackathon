import os
import asyncio
from openai import OpenAI
from backend.utils.config import CHATGPT_API_KEY

# OpenAIクライアントの初期化
client = OpenAI(api_key=CHATGPT_API_KEY)

async def transcribe_and_describe(dish_names: list[str], language: str = "english") -> list[dict[str, str]]:
    """
    日本語の料理名リストを指定された言語で翻訳し、それぞれの簡単な説明を提供します。

    Args:
        dish_names (list[str]): 料理名（日本語）のリスト。
        language (str): 翻訳する言語。'english', 'chinese', 'korean'のいずれか。

    Returns:
        list[dict[str, str]]: 各料理名の日本語、翻訳した言語、説明文を含む辞書のリスト。
    """
    # プロンプトのテンプレート（英語で統一）
    # prompt = (
    #     "Translate the following list of Japanese dish names to {language}, and provide a brief description for each dish in {language}. "
    #     "Please exclude any items that are clearly not food names and any terms that describe a meal course (like 'appetizer') or vague non-dish words. "
    #     "Correct minor typos if needed (e.g., '天ぶら' should be corrected to '天ぷら') and return each translation and description in the format 'Japanese name | Translated name | Description'. "
    #     "For example, 'いちごのパフェ | strawberry parfait | a parfait made with strawberries and cream.'\n\n"
    # )
    prompt = (
        "Translate the following list of Japanese dish names to {language}, and provide a brief description for each dish in {language}. "
        "Please include all food and beverage items, but exclude any items that are clearly not related to food or beverages (e.g., generic terms, non-food items, or meal courses). "
        "Correct any minor typos if needed (e.g., '天ぶら' should be corrected to '天ぷら'). Return each translation and description in the format 'Japanese name | Translated name | Description'. "
        "For example, 'いちごのパフェ | strawberry parfait | a parfait made with strawberries and cream.'\n\n"
    )

    # 言語設定に基づいてプロンプトのプレースホルダを置き換える
    prompt = prompt.format(language=language)

    # 日本語料理名をプロンプトに追加
    prompt += "\n".join(dish_names)

    try:
        # チャットコンプリーションのリクエストを非同期で行う
        chat_completion = await asyncio.to_thread(client.chat.completions.create,
            messages=[{"role": "user", "content": prompt}],
            model="gpt-4o-mini",
        )

        # レスポンスの取得
        response_content = chat_completion.choices[0].message.content.strip()
        # print(response_content)

        # 各行を処理して、日本語名、翻訳された名前、説明文に分割
        results = []
        for line in response_content.splitlines():
            if line.strip():  # 空行は無視
                try:
                    menu_jp, menu_translated, description = [part.strip() for part in line.split("|")]
                    results.append({
                        "Menu_jp": menu_jp,
                        "Menu_en": menu_translated,
                        "Description": description
                    })
                except ValueError:
                    print(f"Failed to parse line: {line}")

        return results

    except Exception as e:
        print(f"An error occurred: {e}")
        return []

# 使用例
if __name__ == "__main__":
    dishes = ["寿司", "天ふら", "ラーマン", "こんにちは", "パスタあ", "ドーナッッ", "600円", "Menu", "前菜"]
    results = asyncio.run(transcribe_and_describe(dishes, language="Chinese"))

    # 元のリストと処理後のリストの比較
    print(f"\n元のリスト: {dishes}")
    
    menus_processed = []
    for result in results:
        menus_processed.append(result['Menu_jp'])
        # print(f"Menu_jp: {result['Menu_jp']}, Menu_en: {result['Menu_en']}, Description: {result['Description']}\n")

    print(f"\n処理後のリスト: {menus_processed}")
    