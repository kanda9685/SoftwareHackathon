// 使うかわからない

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; // ファイルパス操作のために必要
import 'package:menu_app/utils/image_utils.dart'; 
import 'package:menu_app/models/menu_item.dart';

Future<void> uploadImage({
  required BuildContext context,
  required String imagePath,
  required String selectedLanguage,
  required Function(List<MenuItem>) addMenuItems,
  required Function(int) updateIndex,
}) async {
  final file = await rotateAndSaveImage(File(imagePath));  // utils/image_utils.dart のメソッドを使用して画像を回転して保存
  final uploadUrl = 'http://192.168.10.111:8000/process_menus'; // 神田、開発用
  // final uploadUrl = 'http://172.16.0.178:8000/process_menus'; // 横井、開発用

  // 通信中ダイアログを表示
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Loading..."),
          ],
        ),
      );
    },
  );

  try {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl).replace(queryParameters: {'language': selectedLanguage}));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));  // 'file' はサーバー側で期待されるフィールド名

    // リクエストを送信
    final response = await request.send().timeout(const Duration(seconds: 100)); // タイムアウト時間は調整可能

    if (response.statusCode == 200) {
      // アップロード成功時の処理
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      List<dynamic> results = jsonResponse['results'];

      List<MenuItem> items = results.map((item) => MenuItem.fromJson(item)).toList();

      addMenuItems(items);
      updateIndex(1); // メニュー一覧画面に遷移
    } else {
      // アップロード失敗時の処理
      print('Upload failed with status: ${response.statusCode}');
    }
  } catch (e) {
    // エラーハンドリング
    print('Upload failed: $e');
  } finally {
    // 通信中ダイアログを閉じる
    Navigator.of(context, rootNavigator: true).pop();
  }
}
