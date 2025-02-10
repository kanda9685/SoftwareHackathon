## 使い方（フロントエンド）

```
cd menu_app
flutter devices \\device名の把握
flutter run -d <device名>
```

### ローカルでバックエンドサーバーを立てる場合
現状のコードでは、menu_app 内で呼び出すバックエンドサーバーの url は、App Engine 上にあるバックエンドサーバーを参照している。ローカルでバックエンドサーバーを立てる場合は、それらの URL をローカルの IP アドレスに置き換える必要がある。

### スマホとPCがうまくつながらないとき(Android)
https://note-m.com/android%E7%AB%AF%E6%9C%AB%E3%81%8B%E3%82%89%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%ABpc%E3%81%ABhttp%E3%82%A2%E3%82%AF%E3%82%BB%E3%82%B9%E3%81%99%E3%82%8B/

## 使い方（バックエンド）
以降のコマンドは、全て SoftwareHackathon ディレクトリで行う。

### ライブラリのインストール
```
python -m venv venv
. venv/bin/activate
pip install -r backend/requirements.txt     
```

### API キーの設定
backend/utils/config.py に各 API の API Key を設定する。

### サーバーの立ち上げ
```
uvicorn backend.main:app --reload 
```

### テスト用リクエストコマンド

```
curl -X POST "http://127.0.0.1:8000/process_menus" -F "file=@images/menu_images/Menu1.png"
```

### テスト（機能ごと）

画像からメニューのリストを抽出する機能のテスト。
```
python backend/modules/ocr.py
```

単語から画像を検索して返す機能のテスト。（画像が表示される）
```
python backend/modules/image_search.py
```

単語に対して、英訳、英語の説明文を生成する機能のテスト。
```
python backend/modules/menu_description.py  
```

### その他

「backendモジュールが存在しません」みたいなエラーが出た時は、このコマンドを実行したら直るはず（？）
```
export PYTHONPATH=SoftwareHackathonのパス
```
