import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../utils/image_utils.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:menu_app/models/menu_item.dart';


class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(List<MenuItem>) updateMenuItems;
  final Function(int) updateIndex;

  const CameraScreen({
    super.key, 
    required this.camera, 
    required this.updateMenuItems,
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
    final file = await rotateAndSaveImage(File(imagePath));  // utils/image_utils.dart のメソッドを使用して画像を回転して保存
    final uploadUrl = 'http://localhost:8888/process_menus'; // 適切なURLに変更
    // final uploadUrl = 'http://192.168.10.111:8000/process_menus'; // 神田、開発用


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
              Text("通信中..."),
            ],
          ),
        );
      },
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));  // 'file' はサーバー側で期待されるフィールド名
      final response = await request.send().timeout(const Duration(seconds: 100)); // タイムアウト時間は調整可能

      if (response.statusCode == 200) {
        // アップロード成功時の処理
        final responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        List<dynamic> results = jsonResponse['results'];

        List<MenuItem> items = results.map((item) => MenuItem.fromJson(item)).toList();

        widget.updateMenuItems(items);
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


  Widget _buildCameraScreen() {
    return Column(
      children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Expanded(child: CameraPreview(_controller));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
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
