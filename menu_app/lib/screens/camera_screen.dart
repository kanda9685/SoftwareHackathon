import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';  // Providerのインポート
import 'package:menu_app/providers/language_provider.dart';
import '../utils/image_utils.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:menu_app/models/menu_item.dart';
import 'package:geolocator/geolocator.dart';
// 画像選択用のインポートを変更
import 'package:image_picker_web/image_picker_web.dart'; // Web用のimage_picker_webをインポート
import 'package:flutter/foundation.dart'; // kIsWebを使用するために必要

import 'dart:io';


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

  Widget _buildCameraScreen() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ギャラリーの選択ボタン
                      // ギャラリーの選択ボタン部分の変更
                      // カメラボタンの処理変更（Webではカメラは非対応の場合）
                      GestureDetector(
                        onTap: () async {
                          if (kIsWeb) {
                            // Webではカメラ機能は使用せず、画像を選択させる
                            final pickedFile = await ImagePickerWeb.getImageAsBytes(); // Web用の画像選択
                            if (pickedFile != null) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DisplayPictureScreen(
                                    image: '', // 画像データがバイト形式で渡される場合はそのまま利用
                                    addMenuItems: widget.addMenuItems,
                                    updateIndex: widget.updateIndex,
                                  ),
                                ),
                              );
                            }
                          } else {
                            // モバイル用のカメラ処理（既存の処理）
                            try {
                              await _initializeControllerFuture;
                              final image = await _controller.takePicture();
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DisplayPictureScreen(
                                    image: image,
                                    addMenuItems: widget.addMenuItems,
                                    updateIndex: widget.updateIndex,
                                  ),
                                ),
                              );
                            } catch (e) {
                              print(e);
                            }
                          }
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // カメラボタン
                      GestureDetector(
                        onTap: () async {
                          try {
                            await _initializeControllerFuture;
                            final image = await _controller.takePicture();
                            // 撮影後に表示画面に遷移
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DisplayPictureScreen(
                                  image: image,
                                  addMenuItems: widget.addMenuItems,
                                  updateIndex: widget.updateIndex,
                                ),
                              ),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 60), // ボタン間のスペース
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return _buildCameraScreen();
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final dynamic image; // Webの場合はバイトデータ、モバイルの場合はファイルパス
  final Function(List<MenuItem>) addMenuItems;
  final Function(int) updateIndex;

  const DisplayPictureScreen({
    super.key,
    required this.image, // Webの場合はバイトデータ
    required this.addMenuItems,
    required this.updateIndex,
  });

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {

  void _zeroDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Provider.of<LanguageProvider>(context).getLocalizedString('Sorry.')),
          content: Text(Provider.of<LanguageProvider>(context).getLocalizedString('Faildish')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                Navigator.of(context).pop(); // CameraScreenに戻る
              },
              child: Text(Provider.of<LanguageProvider>(context).getLocalizedString('ok')),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Provider.of<LanguageProvider>(context).getLocalizedString('error')),
          content: Text(Provider.of<LanguageProvider>(context).getLocalizedString('failed_to_upload_image')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text(Provider.of<LanguageProvider>(context).getLocalizedString('ok')),
            ),
          ],
        );
      },
    );
  }

    // 位置情報を取得する関数
  Future<Map<String, dynamic>> _getCurrentLocation() async {
    // パーミッションがあるか確認
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {"Latitude": Null, "Longitude": Null};
      }
    }

    // 現在位置を取得
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
        return  {"Latitude": position.latitude, "Longitude": position.longitude};
  }

  Future<void> uploadImage(dynamic image) async {
    String selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    final uploadUrl = 'http://192.168.10.111:8000/process_menus';

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

    final gps_info = await _getCurrentLocation();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadUrl),
      );

      // 位置情報と選択された言語をフィールドとして追加
      request.fields['lat'] = gps_info["Latitude"].toString();
      request.fields['lng'] = gps_info["Longitude"].toString();
      request.fields['language'] = selectedLanguage;

      print(request);

      // Webの場合はバイトデータを使用してMultipartFileを作成
      if (kIsWeb) {
        // imageはバイトデータなので、直接送信
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          image,
          filename: 'image.jpg',  // 任意のファイル名を指定
        ));
      } else {
        // モバイルの場合は、ファイルパスを指定して画像を送信
        final file = await rotateAndSaveImage(File(image));  // File(image) -> File(path)
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      print(request.files);

      final response = await request.send().timeout(const Duration(seconds: 100));

      Navigator.of(context, rootNavigator: true).pop(); // 通信中ダイアログを閉じる

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        List<dynamic> results = jsonResponse['results'];

        List<MenuItem> items = results.map((item) => MenuItem.fromJson(item)).toList();

        if (items.isEmpty) {
          _zeroDialog();
          return;
        }

        widget.addMenuItems(items);
        widget.updateIndex(1);
        Navigator.of(context).pop(); // カメラ画面に戻る
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // 通信中ダイアログを閉じる
      print("Error occurred: $e");
      _showErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Provider.of<LanguageProvider>(context).getLocalizedString('Preview'),
        ),
      ),
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain, // アスペクト比を維持して画面全体に合わせる
          child: Image.memory(
            widget.image, // Webではバイトデータを使用
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await uploadImage(widget.image); // Webの場合はバイトデータを渡す
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}