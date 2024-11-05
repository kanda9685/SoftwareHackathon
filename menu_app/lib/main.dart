import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image/image.dart' as img;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  // 画面の向きを縦向き固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: MyHomePage(camera: firstCamera),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  const MyHomePage({super.key, required this.camera});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<String> _responseitems = [];
  List<String> _responseens = [];

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

  Future<File> rotateAndSaveImage(File imageFile) async {
    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    final rotatedImage = img.copyRotate(originalImage!, angle: 0);
    final newPath = imageFile.path.replaceAll('.jpg', '_rotated.jpg');
    final File newImageFile = File(newPath);
    await newImageFile.writeAsBytes(img.encodeJpg(rotatedImage));

    return newImageFile;
  }

Future<void> uploadImage(String imagePath) async {
  final file = await rotateAndSaveImage(File(imagePath));
  final uploadUrl = 'http://localhost:8888/process_menus'; // 適切なURLに変更

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
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send().timeout(const Duration(seconds: 100));

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      List<dynamic> results = jsonResponse['results'];

      setState(() {
        for (var item in results) {
          _responseitems.add(item['menu_item']);
          _responseens.add(item['menu_en']);
        }
      });
    } else {
      print('Upload failed with status: ${response.statusCode}');
    }
  } catch (e) {
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
              setState(() {
                _selectedIndex = 1;
              });
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ],
    );
  }

  Widget _buildSquareGrid() {
    final itemCount = _responseitems.length < _responseens.length ? _responseitems.length : _responseens.length;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(4.0),
          color: const Color.fromARGB(255, 255, 145, 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      AutoSizeText(
                        _responseitems[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 2,
                        minFontSize: 8,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      AutoSizeText(
                        _responseens[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 2,
                        minFontSize: 8,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildCameraScreen() : _buildSquareGrid(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Menu Items',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
