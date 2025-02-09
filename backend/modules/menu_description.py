import os
import asyncio
from openai import OpenAI
from backend.utils.config import CHATGPT_API_KEY
import re

# OpenAIクライアントの初期化
client = OpenAI(api_key=CHATGPT_API_KEY)

def remove_before_first_japanese(text: str) -> str:
    # 半角数字、全角数字、英字を除外
    text = re.sub(r'[0-9a-zA-Z１-９]', '', text)  # 半角数字、英字、全角数字を除去

    # 日本語の文字を含むパターン (ひらがな、カタカナ、漢字)
    pattern = r'[\u3040-\u30ff\u4e00-\u9faf\u3400-\u4dbf\u20000-\u2a6df]'
    
    # 正規表現で最初の日本語文字を見つける
    match = re.search(pattern, text)
    
    if match:
        # 最初の日本語文字が見つかった場合、その位置以降を返す
        return text[match.start():]
    else:
        # 日本語が含まれていない場合、そのままテキストを返す
        return text
    
def remove_double_quotes(text: str) -> str:
    # ダブルクオーテーションを除外
    return text.replace('"', '')

async def transcribe_and_describe(dish_names: list[str], language: str = "english") -> list[dict[str, str]]:
    """
    料理名のリストを指定された言語で翻訳し、それぞれの簡単な説明を提供します。

    Args:
        dish_names (list[str]): 料理名のリスト。
        language (str): 翻訳する言語。'Japanese', 'english', 'chinese', 'korean', 'Spanish', 'French'のいずれか。

    Returns:
        list[dict[str, str]]: 各料理名の元言語、翻訳した言語、説明文を含む辞書のリスト。
    """
    # プロンプトのテンプレート
    # prompt = (
    #     "Translate the following list of Japanese dish names to {language}, and provide a brief description for each dish in {language}. "
    #     "Please include all food and beverage items, but exclude any items that are clearly not related to food or beverages (e.g., generic terms, non-food items, or meal courses). "
    #     "Correct any minor typos if needed (e.g., '天ぶら' should be corrected to '天ぷら'). For each dish, categorize it into one of the following categories: "
    #     "Main Dishes, Side Dishes, Desserts, Drinks. Please translate the category name into {language} as well. "
    #     "If the input string contains category-related words (e.g., 'デザート', '飲み物', '主菜', 'サイドディッシュ'), use them to assign the correct category based on {language}. "
    #     "If no category-related words are detected or if they don't match one of the categories, assign it to one of these categories: Main Dishes, Side Dishes, Desserts, Drinks. "
    #     "In addition, if a price (e.g., '500円', '1000円') is recognized, include the price alongside the dish name. "
    #     "The price should be appended to the output as '料理名 | Translated name | Description | Category | Price'. If no price is detected, use '-1' as the price. "
    #     "Return each translation and description in the format 'Japanese name | Translated name | Description | Category | Price'. "
    #     "For example, 'いちごのパフェ | strawberry parfait | a parfait made with strawberries and cream. | Desserts | 600'.\n\n"
    # )
    prompt = (
        "Translate each dish name in the list to {language} and provide a brief description in {language}. "
        "Include only food and beverage items, fixing minor typos if needed. "
        "Categorize each dish as Main Dishes, Side Dishes, Desserts, or Drinks, translating the category names into {language}. "
        "If category words are present in the input, use them to guide categorization; otherwise, use the best fit. "
        "If a price is listed, include it as a numerical value without the unit, using '-1' if no price is detected. "
        "Format each item as 'Dish name | Translated name | Description | Category | Price'. "
        "Example: 'いちごのパフェ | strawberry parfait | a parfait made with strawberries and cream. | Desserts | 600'."
    )

    # 言語設定に基づいてプロンプトのプレースホルダを置き換える
    prompt = prompt.format(language=language)

    # 元の料理名をプロンプトに追加
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
        for line in remove_double_quotes(response_content).splitlines():
            if line.strip():  # 空行は無視
                try:
                    menu_jp, menu_translated, description, category, price = [part.strip() for part in line.split("|")]
                    results.append({
                        "Menu_jp": menu_jp,
                        "Menu_en": menu_translated,
                        "Description": description,
                        "Category": category,
                        "Price": int(price) if price.isdigit() else -1
                    })
                except ValueError:
                    print(f"Failed to parse line: {line}")

        return results

    except Exception as e:
        print(f"An error occurred: {e}")
        return []

# 使用例
if __name__ == "__main__":
    # dishes = ["寿司", "天ふら", "ラーマン", "こんにちは", "パスタあ", "ドーナッッ", "ハイボール", "600円", "Menu", "前菜"]
    dishes = ["寿司", "500円", "ラーマン", "200円", "パスタあ", "200円", "ハイボール", "600円", "マグロ"]
    results = asyncio.run(transcribe_and_describe(dishes, language="English"))

    # 元のリストと処理後のリストの比較
    # print(f"\n元のリスト: {dishes}")
    
    menus_processed = []
    for result in results:
        menus_processed.append(result['Menu_jp'])
        print(f"Menu_jp: {result['Menu_jp']}, Menu_en: {result['Menu_en']}, Description: {result['Description']}, Category: {result['Category']} Price: {result['Price']}\n")

    # print(f"\n処理後のリスト: {menus_processed}")
