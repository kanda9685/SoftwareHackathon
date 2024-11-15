#!/bin/bash

# Flutterのインストール・更新
if [ ! -d "./flutter" ]; then
  echo "Flutterがインストールされていないため、Flutterをクローンします..."
  git clone https://github.com/flutter/flutter.git
else
  echo "Flutterを更新します..."
  cd flutter && git pull && cd ..
fi

# Flutterの設定
echo "Flutterの設定を有効化します..."
./flutter/bin/flutter config --enable-web

# Flutterの依存関係をインストール
echo "依存関係をインストールします..."
./flutter/bin/flutter pub get

# Flutter Webビルドを実行
echo "Flutter Webビルドを実行します..."
./flutter/bin/flutter build web --release
