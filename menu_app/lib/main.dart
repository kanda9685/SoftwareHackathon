import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(camera: firstCamera),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<String> _responseitems = []; // 各レスポンスメッセージを格納するリスト
  List<String> _responseens = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Future<void> uploadImage(String imagePath) async {
  final file = File(imagePath);
  final uploadUrl = 'http://172.16.0.178:8000/process_menus'; // 適切なURLに変更

  try {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    // タイムアウトを設定
    final response = await request.send().timeout(const Duration(seconds: 100));

    if (response.statusCode == 200) {
      // レスポンスを文字列として取得
      final responseBody = await response.stream.bytesToString();
      
      // JSONデコード
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      // "results" キーからリストを取得
      List<dynamic> results = jsonResponse['results'];
      
      // 各辞書の要素にアクセスする例
      setState(() {
        _responseitems.clear(); // リストを初期化
        _responseens.clear(); // リストを初期化
        for (var item in results) {
          // 各要素が辞書（Map）として想定されるので、必要なキーにアクセス
          _responseitems.add(item['menu_item']); // メッセージをリストに追加
          _responseens.add(item['menu_en']); // メッセージをリストに追加
        }
      });
    } else {
    print('Upload failed with status: ${response.statusCode}');
      
    }
  } catch (e) {
    print('Upload failed: $e'); // エラーメッセージをリストに追加
    
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
      body: Column(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // 画像をアップロード
            await uploadImage(image.path);

            // 画像を表示する画面に遷移
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SquareGrid(responseitems:_responseitems, responseens:_responseens),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class SquareGrid extends StatelessWidget {
  final List<String> responseitems;
  final List<String> responseens;

  const SquareGrid({
    super.key,
    required this.responseitems,
    required this.responseens,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = responseitems.length < responseens.length ? responseitems.length : responseens.length;

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
                        responseitems[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10, // ベースのフォントサイズを設定
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 2, // 最大2行まで改行を許容
                        minFontSize: 8, // フォントサイズの最小値を設定
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10), // 日本語と英語の間に一定のスペースを確保
                      AutoSizeText(
                        responseens[index],
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
}