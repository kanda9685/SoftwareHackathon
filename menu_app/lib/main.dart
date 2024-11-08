import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_screen.dart';
import 'screens/menu_grid_screen.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:provider/provider.dart'; 
import 'package:menu_app/providers/language_provider.dart';
import 'package:menu_app/providers/camera_provider.dart';
import 'package:menu_app/screens/order_history_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        Provider(create: (context) => CameraProvider(firstCamera)), // CameraProviderを登録
      ],
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

  const MyHomePage({Key? key, required this.camera}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<MenuItem> menuItems = [];

  // 各画面のリストを作成
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CameraScreen(camera: widget.camera, addMenuItems: addMenuItems, updateIndex: updateIndex),
      MenuGridScreen(menuItems: menuItems),
      const OrderHistoryScreen(),
    ];
  }

  // メニューアイテムを追加するメソッド
  void addMenuItems(List<MenuItem> items) {
    setState(() {
      for (var item in items) {
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
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Menu'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.language, color: Colors.white),
                  onPressed: () => _showLanguageDialog(context),
                ),
              ],
            )
          : null,
      body: _screens[_selectedIndex], // 選択された画面を表示
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
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Order History',
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
        return StatefulBuilder( // StatefulBuilderを使用して、ダイアログ内でsetStateを呼び出せるようにする
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
                    if (_tempSelectedLanguage != Provider.of<LanguageProvider>(context, listen: false).selectedLanguage) {
                      Provider.of<LanguageProvider>(context, listen: false)
                          .updateLanguage(_tempSelectedLanguage);
                      if (menuItems.isNotEmpty) {
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
                    Navigator.of(context).pop();
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
    final url = 'http://192.168.10.111:8000/translate_menus';

    try {
      final menuJpList = menuItems.map((item) => item.menuJp).toList();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'menu_items': menuJpList,
          'language': selectedLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        setState(() {
          for (int i = 0; i < menuItems.length; i++) {
            menuItems[i].menuEn = results[i]['menu_en'];
            menuItems[i].description = results[i]['description'];
            menuItems[i].selectedLanguage = selectedLanguage;
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
