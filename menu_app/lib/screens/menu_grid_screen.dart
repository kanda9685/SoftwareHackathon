import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:menu_app/screens/order_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:provider/provider.dart';  // Providerのインポート
import '../providers/language_provider.dart';  // LanguageProviderのインポート
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// 翻訳のエンドポイントを変更する必要がある

String MAIN_URL = "http://172.16.0.178:8000";

// メニュー画面
class MenuGridScreen extends StatefulWidget {
  final List<MenuItem> menuItems;

  const MenuGridScreen({super.key, required this.menuItems});

  @override
  _MenuGridScreenState createState() => _MenuGridScreenState();
}

class _MenuGridScreenState extends State<MenuGridScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          // 言語設定ボタンの追加
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () => _showLanguageDialog(context), // 言語選択ダイアログを表示
          ),
          // ゴミ箱アイコンの追加
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _showDeleteConfirmationDialog(context); // ゴミ箱アイコンがタップされたときに確認ダイアログを表示
            },
          ),
        ],
      ),
      body: widget.menuItems.isEmpty
        ? const Center(child: Text("No menus."))
        : Column(
          children: [
            // メニューアイテムのグリッド表示
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                ),
                itemCount: widget.menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = widget.menuItems[index];

                  return GestureDetector(
                    onTap: () {
                      _showMenuItemDialog(context, menuItem, (updatedMenuItem) {
                        setState(() {
                          // 親ウィジェットの状態を更新
                          widget.menuItems[index] = updatedMenuItem;
                        });
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // 背景色を常に灰色に
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // メニューアイテムの内容部分
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // 画像部分 (上側は丸く、下側は直線)
                              Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        child: Image.network(
                                          menuItem.imageUrls![0],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                                size: 30,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                              ),
                              // メニューのテキスト部分
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      AutoSizeText(
                                        menuItem.menuJp,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          decoration: TextDecoration.none,
                                        ),
                                        maxLines: 2,
                                        minFontSize: 6,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      AutoSizeText(
                                        menuItem.menuEn,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          decoration: TextDecoration.none,
                                        ),
                                        maxLines: 2,
                                        minFontSize: 6,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // 右下に個数を表示
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '×${menuItem.quantity}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // 注文ボタン
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // 注文画面に遷移
                  List<MenuItem> selectedItems = widget.menuItems.where((item) => item.quantity > 0).toList();
                  if (selectedItems.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderScreen(selectedItems: selectedItems),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.checklist, size: 20), // アイコンの追加
                    SizedBox(width: 8), // アイコンとテキストの間にスペースを追加
                    Text('Order'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

  Future<void> _updateLanguageForMenuItems() async {
    String selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    
    final url = '${MAIN_URL}/translate_menus'; // メニューの翻訳エンドポイント

    try {
      // メニューアイテムを送信する前に、menu_jp のリストを作成
      final menuJpList = widget.menuItems.map((item) => item.menuJp).toList();

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
          for (int i = 0; i < widget.menuItems.length; i++) {
            widget.menuItems[i].menuEn = results[i]['menu_en']; // 翻訳されたメニュー
            widget.menuItems[i].description = results[i]['description']; // 翻訳された説明
            widget.menuItems[i].selectedLanguage = selectedLanguage; // 言語設定を更新
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
                    if (widget.menuItems.isNotEmpty) {
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    // メニューリストを削除する確認ダイアログ
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Menus'),
          content: const Text('Are you sure you want to delete all menu items?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.menuItems.clear(); // メニューリストをクリア
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  bool isUploading = false;

  void _showMenuItemDialog(
      BuildContext context, MenuItem menuItem, Function(MenuItem) onQuantityUpdated) {
    int tempQuantity = menuItem.quantity;
    int currentImageIndex = 0;

    
    // Thank You メッセージを表示するダイアログ
    void _showThankYouDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Thank you!"),
            content: Text("Your image has been uploaded successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

    // エラーメッセージを表示するダイアログ
    void _showErrorDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to upload image. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

    // 画像選択のためのImagePickerインスタンス
    final ImagePicker _picker = ImagePicker();
    File? _selectedImage;

    Future<void> _uploadImage(File imageFile) async {
      try{
        setState(() {
          isUploading = true;
        });

        // サーバーのエンドポイントURL
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("${MAIN_URL}/image_upload")
        );

        request.fields['file_name'] = menuItem.menuJp;

        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          _showThankYouDialog();
        } else {
          _showErrorDialog();
        } 
      } catch (e) {
        // エラーハンドリング
        _showErrorDialog();
      } finally {
          setState(() {
            isUploading = false;
          });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 画像領域と矢印ボタン
                        Container(
                          width: double.infinity,
                          height: 250.0,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    menuItem.imageUrls![currentImageIndex],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey[700],
                                          size: 50,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // 左矢印ボタン
                              if (currentImageIndex > 0)
                                Positioned(
                                  left: 5,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back, color: Colors.black54),
                                    onPressed: () {
                                      setState(() {
                                        currentImageIndex = (currentImageIndex - 1) % menuItem.imageUrls!.length;
                                      });
                                    },
                                  ),
                                ),
                              // 右矢印ボタン
                              if (currentImageIndex < menuItem.imageUrls!.length - 1)
                                Positioned(
                                  right: 5,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_forward, color: Colors.black54),
                                    onPressed: () {
                                      setState(() {
                                        currentImageIndex = (currentImageIndex + 1) % menuItem.imageUrls!.length;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AutoSizeText(
                          menuItem.menuJp,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          minFontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        AutoSizeText(
                          menuItem.menuEn,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          minFontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            menuItem.description,
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 個数選択
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  if (tempQuantity > 0) {
                                    tempQuantity--;
                                  }
                                });
                              },
                            ),
                            Text('$tempQuantity', style: const TextStyle(fontSize: 18, color: Colors.black)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  if (tempQuantity < 10) {
                                    tempQuantity++;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                        // 画像アップロードボタン
                        children: [
                          ElevatedButton(
                            onPressed: isUploading ? null :() async {
                              final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                _selectedImage = File(pickedFile.path);
                                await _uploadImage(_selectedImage!);
                                setState(() {});  // 状態を更新してUIを再描画
                              }
                            },
                           child: isUploading 
                                ? const CircularProgressIndicator()  // アップロード中はインジケーター表示
                                : const Text('Upload Image'),
                          ),
                          const SizedBox(width: 30),
                          // 追加ボタン
                          ElevatedButton(
                            onPressed: () {
                              onQuantityUpdated(MenuItem(
                                menuJp: menuItem.menuJp,
                                menuEn: menuItem.menuEn,
                                description: menuItem.description,
                                imageUrls: menuItem.imageUrls,
                                quantity: tempQuantity,
                              ));
                              Navigator.of(context).pop();
                            },
                            child: const Text('Confirm'),
                          )],
                        )
                      ],
                    ),
                  ),
                  // バツボタンを右上に配置
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}