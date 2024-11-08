import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_screen.dart';
import 'screens/menu_grid_screen.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:provider/provider.dart'; 
import 'package:menu_app/providers/language_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),  // LanguageProviderを提供
      child: MyApp(camera: firstCamera),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  const MyHomePage({super.key, required this.camera});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<MenuItem> menuItems = [];

  // メニューアイテムを追加するメソッド
  void addMenuItems(List<MenuItem> items) {
    setState(() {
      // 受け取ったアイテムをmenuItemsに追加
      for (var item in items) {
        // menuJpがすでに存在する場合は追加しない
        if (!menuItems.any((existingItem) => existingItem.menuJp == item.menuJp)) {
          menuItems.add(item);
        }
      }
    });
  }

  // 画面遷移を行うメソッド
  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 // selectedIndex が 0 の場合は AppBar を表示
          ? AppBar(
              title: const Text('Menu'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.language, color: Colors.white),
                  onPressed: () => _showLanguageDialog(context), // 言語選択ダイアログを表示
                ),
              ],
            )
          : null, // selectedIndex が 0 でない場合は AppBar を非表示
      body: _selectedIndex == 0 
        ? CameraScreen(camera: widget.camera, addMenuItems: addMenuItems, updateIndex: updateIndex)
        : MenuGridScreen(menuItems: menuItems),
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

  // 言語選択ダイアログの表示
  void _showLanguageDialog(BuildContext context) {
  String _tempSelectedLanguage = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(  // StatefulBuilderを使用して、ダイアログ内でsetStateを呼び出せるようにする
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Select Language"),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: <String>['English', 'Chinese', 'Korean']
                    .map((String language) {
                  return ListTile(
                    title: Text(language),
                    trailing: _tempSelectedLanguage == language
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      // タップ時に選択された言語を更新し、setStateでUIを更新
                      setState(() {
                        _tempSelectedLanguage = language;
                      });
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
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  // 言語が変更された場合のみ更新を実行
                  if (_tempSelectedLanguage != Provider.of<LanguageProvider>(context, listen: false).selectedLanguage) {
                    // 言語の更新を行う
                    Provider.of<LanguageProvider>(context, listen: false)
                        .updateLanguage(_tempSelectedLanguage);
                    if (menuItems.isNotEmpty) {
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
                      await _updateLanguageForMenuItems();
                      Navigator.of(context).pop(); 
                    }
                  }
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );
    },
  );
  }

  Future<void> _updateLanguageForMenuItems() async {
    String selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    
    final url = 'http://192.168.10.111:8000/translate_menus'; // メニューの翻訳エンドポイント

    try {
      // メニューアイテムを送信する前に、menu_jp のリストを作成
      final menuJpList = menuItems.map((item) => item.menuJp).toList();

      // リクエストの送信
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // UTF-8 エンコーディングを指定
        },
        body: json.encode({
          'menu_items': menuJpList,
          'language': selectedLanguage,
        }),
      );

      if (response.statusCode == 200) {

        final data = json.decode(response.body);
        final results = data['results'] as List;

        // メニューアイテムごとに更新
        setState(() {
          for (int i = 0; i < menuItems.length; i++) {
            menuItems[i].menuEn = results[i]['menu_en']; // 翻訳されたメニュー
            menuItems[i].description = results[i]['description']; // 翻訳された説明
            menuItems[i].selectedLanguage = selectedLanguage; // 言語設定を更新
          }
        });
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to update menu items');
      }
    } catch (e) {
      print('Error updating language for menu items: $e');
    }
  }
}
