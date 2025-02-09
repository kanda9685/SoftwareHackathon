import os
from dotenv import load_dotenv

# 環境変数を読み込む
load_dotenv()

CHATGPT_API_KEY = os.getenv("CHATGPT_API_KEY") # ChatGPT API の Key
GOOGLE_SEARCH_API_KEY = os.getenv("GOOGLE_SEARCH_API_KEY") # Google Custom Search API の Key
CSE_ID = os.getenv("CSE_ID") # Google の検索エンジンID
GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY") #Place APIのAPIkey