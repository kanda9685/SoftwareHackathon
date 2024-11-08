import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Providerのインポート
import 'package:menu_app/providers/language_provider.dart';
import '../utils/image_utils.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:menu_app/models/menu_item.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(List<MenuItem>) addMenuItems;
  final Function(int) updateIndex;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.addMenuItems,
    required this.updateIndex,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  List<MenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> uploadImage(String imagePath) async {
    // 言語設定を取得
    String selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    final file = await rotateAndSaveImage(File(imagePath));  // utils/image_utils.dart のメソッドを使用して画像を回転して保存
    final uploadUrl = 'http://192.168.10.111:8000/process_menus'; // 神田、開発用

    // 通信中ダイアログを表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(languageProvider.getLocalizedString('loading')),
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

        widget.addMenuItems(items);
        widget.updateIndex(1); // メニュー一覧画面に遷移
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Language"),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: <String>['English', 'Chinese', 'Korean']
                  .map((String language) {
                return ListTile(
                  title: Text(language),
                  trailing: Provider.of<LanguageProvider>(context).selectedLanguage == language
                      ? Icon(Icons.check, color: Colors.blue) // 選択済みにチェック
                      : null,
                  onTap: () {
                    // 言語変更をProviderに通知
                    Provider.of<LanguageProvider>(context, listen: false).updateLanguage(language);
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // キャンセルボタンでダイアログを閉じる
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCameraScreen() {
    return Column(
      children: [
        Expanded(  // Stackが親サイズを持つようにExpandedを使う
          child: Stack(
            fit: StackFit.expand,  // Stack内で子ウィジェットが親サイズを占める
            children: [
              // カメラプレビュー
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);  // カメラプレビューを表示
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              // 設定用の半透明ボタンを右下に配置
              // Positioned(
              //   right: 5,
              //   bottom: 5, // 撮影ボタンとの位置調整
              //   child: Opacity(
              //     opacity: 0.7, // 半透明に設定
              //     child: FloatingActionButton(
              //       onPressed: _showLanguageDialog,
              //       child: const Icon(Icons.settings),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        // 撮影ボタン
        FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              await uploadImage(image.path);
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCameraScreen();
  }
}
