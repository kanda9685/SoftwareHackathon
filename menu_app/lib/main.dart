import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_screen.dart';
import 'screens/menu_grid_screen.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:provider/provider.dart'; 
import 'package:menu_app/providers/language_provider.dart';
import 'package:menu_app/providers/camera_provider.dart';
import 'package:menu_app/screens/order_history_screen.dart';
import 'package:menu_app/providers/menu_items_provider.dart';
import 'package:menu_app/screens/order_screen.dart'; // OrderScreen をインポート
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
        ChangeNotifierProvider(create: (context) => CameraProvider(firstCamera)),
        ChangeNotifierProvider(create: (context) => MenuItemsProvider()), 
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
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          theme: ThemeData.dark(),
          home: MyHomePage(camera: camera),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int selectedIndex;
  final CameraDescription camera;

  MyHomePage({Key? key, required this.camera, this.selectedIndex = 0}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex;
  List<MenuItem> menuItems = [];

  // 各画面のリストを作成
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    final menuItemsProvider = Provider.of<MenuItemsProvider>(context, listen: false);
    menuItems = menuItemsProvider.menuItems;
    _screens = [
      CameraScreen(camera: widget.camera, addMenuItems: addMenuItems, updateIndex: updateIndex),
      MenuGridScreen(menuItems: menuItems),
      const OrderHistoryScreen(),
      OrderScreen(selectedItems: menuItems), // OrderScreen を追加
    ];
    _selectedIndex = widget.selectedIndex;
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
          title: Text('MenuBite'), // 動的にメニュータイトルを変更
          actions: [
            TextButton(
              onPressed: () => _showLanguageDialog(context),
              child: Text(
                'Lang: ${Provider.of<LanguageProvider>(context).getLanguageShortCode()}', // Langを適用
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // 横線の高さを指定
            child: Container(
              color: Colors.grey, // 横線の色を指定
              height: 0.5, // 横線の太さを指定
            ),
          ),
        )
        : null,
      body: _screens[_selectedIndex], // 選択された画面を表示
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.grey, // 横線の色
            height: 0.5, // 横線の高さ（太さ）
          ),
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: Provider.of<LanguageProvider>(context).getLocalizedString('camera'), // 言語に基づくボタンラベル
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_on),
                label: Provider.of<LanguageProvider>(context).getLocalizedString('menu items'), // 言語に基づくボタンラベル
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: Provider.of<LanguageProvider>(context).getLocalizedString('order_history'), // 言語に基づくボタンラベル
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Colors.white,  // 選択時のアイコン色を白に設定
            unselectedItemColor: Colors.grey, // 非選択時のアイコン色をグレーに設定
            backgroundColor: Colors.black, // 背景色を黒に設定（必要に応じて変更）
          ),
        ],
      )
    );
  }

  
  Future<void> selectDeleteMenu(BuildContext context)async{
    // メニューリストを削除する確認ダイアログ
    print("llll");
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        print("hhhhh");
        final languageProvider = Provider.of<LanguageProvider>(context);
        return AlertDialog(
          title: Text(languageProvider.getLocalizedString('delete_all_menus')),
          content: Text(languageProvider.getLocalizedString('delete_all_menus_forlang'),
          style: TextStyle(
            fontSize: 16,
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.getLocalizedString('dontdelete')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  menuItems.clear(); // メニューリストをクリア
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.getLocalizedString('delete')),
            ),
          ],
        );
      },
    );
  }
   

  // 言語選択ダイアログの表示
  void _showLanguageDialog(BuildContext context) {
    String _tempSelectedLanguage = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(  // StatefulBuilderを使用して状態管理を行う
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(Provider.of<LanguageProvider>(context, listen: false).getLocalizedString('select_language')), // 言語選択タイトル
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: <String>['English', 'Korean', 'Chinese', 'Spanish', 'French']
                      .map((String language) {
                    return ListTile(
                      title: Text(Provider.of<LanguageProvider>(context, listen: false).getLanguageFullName(language)), // フルネームを表示
                      trailing: _tempSelectedLanguage == language
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _tempSelectedLanguage = language;  // タップした言語をセット
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();  // ダイアログを閉じる
                  },
                  child: Text(Provider.of<LanguageProvider>(context, listen: false).getLocalizedString('cancel')), // キャンセルボタン
                ),
                TextButton(
                  onPressed: () {
                    if (_tempSelectedLanguage != Provider.of<LanguageProvider>(context, listen: false).selectedLanguage) {

                      Provider.of<LanguageProvider>(context, listen: false).updateLanguage(_tempSelectedLanguage);  // 言語を更新
                      
                      if(menuItems.isNotEmpty){
                        selectDeleteMenu(context);
                      }
                    }else{
                      Navigator.of(context).pop();
                    }
                    
                  },
                  child: Text(Provider.of<LanguageProvider>(context, listen: false).getLocalizedString('confirm')), // 確認ボタン
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
