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
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    Provider.of<LanguageProvider>(context, listen: false).updateLanguage(language);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    imagePath: image.path,
                    addMenuItems: widget.addMenuItems,
                    updateIndex: widget.updateIndex,
                  ),
                ),
              );
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

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Function(List<MenuItem>) addMenuItems;
  final Function(int) updateIndex;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
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

  Future<void> uploadImage(String imagePath) async {
    String selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;

    final file = await rotateAndSaveImage(File(imagePath));
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
    
      request.fields['lat'] = gps_info["Latitude"].toString();
      request.fields['lng'] = gps_info["Longitude"].toString();
      request.fields['language'] = selectedLanguage;

      print(request);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      print(request.files);

      final response = await request.send().timeout(const Duration(seconds: 100));

      print(selectedLanguage);
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
      appBar: AppBar(title: Text(Provider.of<LanguageProvider>(context).getLocalizedString('Preview'))),
      body: Image.file(File(widget.imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await uploadImage(widget.imagePath);
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}