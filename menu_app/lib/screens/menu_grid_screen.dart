import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:menu_app/screens/order_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:provider/provider.dart';  // Providerのインポート
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:menu_app/providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// 翻訳のエンドポイントを変更する必要がある

String MAIN_URL = "http://192.168.10.111:8000";

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
  final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: widget.menuItems.isEmpty || widget.menuItems[0].shopName.isEmpty
          ? Text(languageProvider.getLocalizedString('_menu'))  // shopNameが空の場合、メニュー表示
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: languageProvider.getMenuTitleOrder() == 'front'
                  ? Text(widget.menuItems[0].shopName + languageProvider.getLocalizedString('menu'))
                  : Text(languageProvider.getLocalizedString('menu') + widget.menuItems[0].shopName),
            ),
        actions: [
          // 言語設定ボタンの追加
          TextButton(
            onPressed: () => _showLanguageDialog(context),
            child: Text(
              'Lang: ${Provider.of<LanguageProvider>(context).getLanguageShortCode()}', // Langを適用
              style: const TextStyle(color: Colors.white),
            ),
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
        ? Center(child: Text(languageProvider.getLocalizedString('no_menu')))
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
                                child: menuItem.base64Image.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      child: Image.memory(
                                        base64Decode(menuItem.base64Image), // base64Imageをデコードして表示
                                        fit: BoxFit.cover,
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
                                  : (menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          child: Image.network(
                                            menuItem.imageUrls![0], // 通常のURL
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
                                        )),
                              ),
                              // メニューのテキスト部分
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20), 
                                      AutoSizeText(
                                        menuItem.menuEn,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                        ),
                                        maxLines: 2,
                                        minFontSize: 6,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      AutoSizeText(
                                        menuItem.menuJp,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
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
                  children: [
                    const Icon(Icons.checklist, size: 20), // アイコンの追加
                    const SizedBox(width: 8), // アイコンとテキストの間にスペースを追加
                    Text(languageProvider.getLocalizedString('order')),
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
      final languageProvider = Provider.of<LanguageProvider>(context);
      return StatefulBuilder(  // StatefulBuilderを使用して、ダイアログ内でsetStateを呼び出せるようにする
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(languageProvider.getLocalizedString('select_language')),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: <String>['English', 'Korean', 'Chinese', 'Spanish', 'French']
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
                child: Text(languageProvider.getLocalizedString('cancel')),
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
                      await _updateLanguageForMenuItems();
                      Navigator.of(context).pop(); 
                    }
                  }
                  Navigator.of(context).pop();
                },
                child: Text(languageProvider.getLocalizedString('confirm')),
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
        final languageProvider = Provider.of<LanguageProvider>(context);
        return AlertDialog(
          title: Text(languageProvider.getLocalizedString('delete_all_menus')),
          content: Text(languageProvider.getLocalizedString('delete_all_menus_confirmation'),
          style: TextStyle(
            fontSize: 16,
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.getLocalizedString('cancel')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.menuItems.clear(); // メニューリストをクリア
                });
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.getLocalizedString('delete')),
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
          final languageProvider = Provider.of<LanguageProvider>(context);
          return AlertDialog(
            title: Text(languageProvider.getLocalizedString('thank_you')),
            content: Text(languageProvider.getLocalizedString('image_uploaded')),
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
          final languageProvider = Provider.of<LanguageProvider>(context);
          return AlertDialog(
            title: Text(languageProvider.getLocalizedString('error')),
            content: Text(languageProvider.getLocalizedString('failed_to_upload_image')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: Text(languageProvider.getLocalizedString('ok')),
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

    Future<String> regenerateImage(String menuName) async {
      final url = '${MAIN_URL}/generate-image';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // UTF-8 エンコーディングを指定
        },
        body: json.encode({
          'menu_name': menuName
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        return responseData['image_base64'];  // 生成された画像のBase64データを返す
      } else {
        throw Exception('Failed to regenerate image');
      }
    }

  showDialog(
  context: context,
  builder: (BuildContext context) {
    bool _isRotating = false; // アイコンが回転中かどうかの状態
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      child: StatefulBuilder(
        builder: (context, setState) {
          // 現在表示している画像インデックス（base64 + imageUrls を考慮）
          int totalImagesCount = 0;
          if (menuItem.base64Image.isNotEmpty) {
            totalImagesCount++; // base64Imageがあれば1枚目としてカウント
          }
          if (menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty) {
            totalImagesCount += menuItem.imageUrls!.length; // imageUrlsの枚数をカウント
          }

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
                              child: totalImagesCount == 0
                                  ? Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[700],
                                        size: 50,
                                      ),
                                    )
                                  : menuItem.base64Image.isNotEmpty
                                    ? currentImageIndex == 0
                                      ? Image.memory(
                                          base64Decode(menuItem.base64Image), // Base64データをデコードして表示
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
                                        )
                                      : menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty
                                          ? Image.network(
                                              menuItem.imageUrls![currentImageIndex - 1], // 2枚目以降の画像
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(child: CircularProgressIndicator());
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey[700],
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey[700],
                                                size: 50,
                                              ),
                                            )
                                    : Image.network(
                                        menuItem.imageUrls![currentImageIndex], // 2枚目以降の画像
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey[700],
                                              size: 50,
                                            ),
                                          );
                                        },
                                      )
                            )
                          ),
                          // 左矢印ボタン（Base64がない場合、imageUrlsがある場合に表示）
                          if (currentImageIndex > 0)
                            Positioned(
                              left: 5,
                              top: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.black54),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex = (currentImageIndex - 1) % totalImagesCount;
                                  });
                                },
                              ),
                            ),
                          // 右矢印ボタン（Base64がない場合、imageUrlsがある場合に表示）
                          if (currentImageIndex < totalImagesCount - 1)
                            Positioned(
                              right: 5,
                              top: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward, color: Colors.black54),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex = (currentImageIndex + 1) % totalImagesCount;
                                  });
                                },
                              ),
                            ),
                          // 再生成ボタン（右下）
                          Positioned(
                            right: 5,
                            bottom: 5,
                            child: IconButton(
                              icon: AnimatedContainer(
                                padding: const EdgeInsets.all(4.0),  // アイコンの周りの余白
                                duration: Duration(milliseconds: 300), // アニメーションの長さ
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),  // アイコンの背景色
                                  shape: BoxShape.circle,  // 背景を丸くする
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6.0,
                                      color: Colors.black.withOpacity(0.2),  // 影の色
                                      offset: Offset(2, 2),  // 影の位置
                                    ),
                                  ],
                                ),
                                child: AnimatedRotation(
                                  turns: _isRotating ? 100 : 0, // クリックされたときに回転
                                  duration: Duration(seconds: 100), // 回転のアニメーションの長さ
                                  child: Icon(
                                    Icons.refresh,  // 再生成アイコン
                                    color: Colors.blue,
                                    size: 25.0,  // アイコンのサイズ
                                  ),
                                ),
                              ),

                              onPressed: () async {
                                // アニメーションを開始
                                setState(() {
                                  _isRotating = true;
                                });

                                // ローディング画面を表示
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    final languageProvider = Provider.of<LanguageProvider>(context);
                                    return AlertDialog(
                                      content: Row(
                                        children: [
                                          Text(languageProvider.getLocalizedString('generating')),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                try {
                                  // API呼び出しを行い、画像を再生成
                                  String newImageBase64 = await regenerateImage(menuItem.menuJp);

                                  setState(() {
                                    menuItem.isBase64Image = true; // Base64形式の画像として扱う
                                    menuItem.base64Image = newImageBase64;  // 新しい画像データをBase64としてセット
                                    currentImageIndex = 0;  // 生成したばかりの画像を表示
                                  });
                                } catch (e) {
                                  // エラーハンドリング
                                  print("Error generating image: $e");
                                } finally {
                                  Navigator.pop(context); // ローディングダイアログを閉じる
                                }

                                setState(() {
                                  _isRotating = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,  // 水平中央揃え
                      children: [
                        // AutoSizeText: メニュー名
                        AutoSizeText(
                          menuItem.menuEn,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,

                          decoration: TextDecoration.underline, 
                          decorationColor: Colors.blue,
                          decorationThickness: 1.0,
                          ),
                          maxLines: 2,
                          minFontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 5),  // テキストとアイコンの間に余白を追加
                        // GestureDetector: 検索アイコン
                        GestureDetector(
                          onTap: () async {
                            final url = 'https://www.google.com/search?q=${Uri.encodeComponent(menuItem.menuEn)}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Icon(
                            Icons.search,  // 検索アイコン
                            color: Colors.blue,  // アイコンの色
                            size: 24,  // アイコンのサイズ
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 10),
                    // AutoSizeText(
                    //   menuItem.menuJp,
                    //   style: const TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    //   maxLines: 2,
                    //   minFontSize: 12,
                    //   overflow: TextOverflow.ellipsis,
                    //   textAlign: TextAlign.center,
                    // ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                        Text(
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
                      child: Text(Provider.of<LanguageProvider>(context).getLocalizedString('confirm')),
                    ),
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
).then((value) {
  // ダイアログが閉じられた後の処理を行う
  setState(() {});
});


  }
}