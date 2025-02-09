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
import 'package:menu_app/providers/menu_items_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 翻訳のエンドポイントを変更する必要がある

String MAIN_URL = "https://menubite2.uc.r.appspot.com";

// メニュー画面
class MenuGridScreen extends StatefulWidget {
  final List<MenuItem> menuItems;

  const MenuGridScreen({super.key, required this.menuItems});

  @override
  _MenuGridScreenState createState() => _MenuGridScreenState();
}

class _MenuGridScreenState extends State<MenuGridScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _categories;
  late List<MenuItem> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.menuItems; 
    _initializeTabController();
    if (_categories.isNotEmpty) {
      _filterItemsByCategory(_categories[0]);
    }

    // 初期化時に全menuItemsに対して非同期で画像生成を実行
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _fetchOrGenerateImagesForAllItems(); // 画像生成の非同期処理を開始
    // });
  }

  // タブを初期化する関数
  void _initializeTabController() {
    _categories = widget.menuItems
        .map((item) => item.category)
        .toSet()
        .toList();

    // カテゴリが存在する場合のみTabControllerを初期化する
    if (_categories.isNotEmpty) {
      _tabController = TabController(length: _categories.length, vsync: this);
    } else {
      // カテゴリが空の場合、デフォルトで1つのタブを設定
      _categories = ['Default Category'];  // 例: 'Default Category'
      _tabController = TabController(length: 1, vsync: this);
    }
  }

  // カテゴリを変更してフィルタリングする関数
  void _filterItemsByCategory(String category) {
    setState(() {
      _filteredItems = widget.menuItems.where((item) => item.category == category).toList();
    });
  }

  // カテゴリリストが変更されたときにTabControllerを更新
  void updateCategories() {
    setState(() {
      _tabController.dispose();
      _initializeTabController();  // TabControllerを再初期化
    });
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

  // imageUrls が空かどうかの判定
  bool isFirstElementEmptyString(List<String>? imageUrls) {
    // imageUrls が null ではなく、かつリストの最初の要素が空文字列であるかをチェック
    if (imageUrls != null && imageUrls.isNotEmpty) {
      return imageUrls[0] == '';  // 最初の要素が空文字列かどうか
    }
    return false;
  }

  // 各menuItemの画像生成を並行して非同期に実行する関数
  // void _fetchOrGenerateImagesForAllItems() async {
  //   for (var menuItem in widget.menuItems) {
  //     if (isFirstElementEmptyString(menuItem.imageUrls) 
  //         && menuItem.base64Image.isEmpty 
  //         && menuItem.isLoading == false) {
  //       setState(() {
  //         menuItem.isLoading = true; // 画像生成開始時にisLoadingをtrueに設定
  //       });

  //       regenerateImage(menuItem.menuJp).then((newImageBase64) {
  //         setState(() {
  //           menuItem.isBase64Image = true;
  //           menuItem.base64Image = newImageBase64;
  //           menuItem.isLoading = false; // 画像生成後にisLoadingをfalseに戻す
  //         });
  //       }).catchError((e) {
  //         print("Error generating image for ${menuItem.menuJp}: $e");
  //         setState(() {
  //           menuItem.isLoading = false; // エラー時にもisLoadingをfalseに設定
  //         });
  //       });
  //     }
  //   }
  //   print("All images have been generated.");
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // 総合計金額を計算
    int totalPrice = 0;
    for (var menuItem in widget.menuItems) {
      // 価格が負でない場合のみ計算に加算
      if (menuItem.price >= 0) {
        totalPrice += menuItem.price * menuItem.quantity;
      }
    }

    // 合計金額が負の場合は "￥-xxx" という形式で表示
    String totalPriceString = totalPrice < 0 ? '￥-${totalPrice.abs()}' : '￥${totalPrice}';

    return Scaffold(
      appBar: AppBar(
        title: widget.menuItems.isEmpty || widget.menuItems[0].shopName.isEmpty
            ? Text(languageProvider.getLocalizedString('_menu'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: languageProvider.getMenuTitleOrder() == 'front'
                    ? Text(widget.menuItems[0].shopName + languageProvider.getLocalizedString('menu'))
                    : Text(languageProvider.getLocalizedString('menu') + widget.menuItems[0].shopName),
              ),
        actions: [
          TextButton(
            onPressed: () => _showLanguageDialog(context),
            child: Text(
              'Lang: ${Provider.of<LanguageProvider>(context).getLanguageShortCode()}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // 横線の高さを指定
          child: Container(
            color: Colors.grey, // 横線の色を指定
            height: 0.5, // 横線の太さを指定
          ),
        ),
      ),
      body: widget.menuItems.isEmpty
          ? Center(child: Text('No menu available'))
          : Column(
              children: [
                // タブバーを追加
                Container(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    onTap: (index) {
                      _filterItemsByCategory(_categories[index]); // タブをタップした際にカテゴリをフィルタリング
                    },
                    tabs: _categories
                        .map((category) => Tab(
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 16.0, // 文字の大きさを変更（必要に応じて調整）
                                ),
                              ),
                            ))
                        .toList(),
                    padding: EdgeInsets.zero, // パディングをゼロにして余白をなくす
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ),
                // タブの内容を表示する部分
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final menuItem = _filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          _showMenuItemDialog(context, menuItem
                          );
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
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
                                    child: menuItem.isLoading
                                        ? Center( // 画像生成中のローディングインジケーター
                                            child: CircularProgressIndicator(),
                                          )
                                        : menuItem.base64Image.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                              child: Image.memory(
                                                base64Decode(menuItem.base64Image),
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
                                                child: CachedNetworkImage(
                                                  imageUrl: menuItem.imageUrls![0],
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                  errorWidget: (context, url, error) => const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                  size: 30,
                                                )),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // Column内で中央揃え
                                        crossAxisAlignment: CrossAxisAlignment.center, // 横の中央揃え
                                        children: [
                                          AutoSizeText(
                                            menuItem.menuEn,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold
                                            ),
                                            maxLines: 2,  // 最大2行まで
                                            minFontSize: 8,  // 最小フォントサイズを8に設定（任意）
                                            overflow: TextOverflow.ellipsis,  // オーバーフロー時に省略記号を表示
                                            textAlign: TextAlign.center,
                                          ),
                                          AutoSizeText(
                                            menuItem.menuJp,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              decoration: TextDecoration.none,
                                            ),
                                            maxLines: 2,  // 最大2行まで
                                            minFontSize: 6,  // 最小フォントサイズを6に設定（任意）
                                            overflow: TextOverflow.ellipsis,  // オーバーフロー時に省略記号を表示
                                            textAlign: TextAlign.center,
                                          ),
                                          AutoSizeText(
                                            menuItem.price < 0 ? '¥-' : '¥${menuItem.price}',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              decoration: TextDecoration.none,
                                            ),
                                            maxLines: 1,  // 価格は1行で表示
                                            minFontSize: 6,  // 最小フォントサイズを6に設定（任意）
                                            overflow: TextOverflow.ellipsis,  // オーバーフロー時に省略記号を表示
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
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
                ElevatedButton(
                  onPressed: () {
                    List<MenuItem> selectedItems = widget.menuItems.where((item) => item.quantity > 0).toList();
                    if (selectedItems.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ChangeNotifierProvider.value(
                              value: Provider.of<MenuItemsProvider>(context, listen: true),
                              child: OrderScreen(selectedItems: selectedItems),
                            );
                          },
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // ボタン内のパディングを調整
                      minimumSize: Size(200, 50), // 最小サイズを指定（幅200、高さ50）
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 角を丸くする
                      ),
                    side: BorderSide(
                      color: Colors.grey, // 枠線の色を指定
                      width: 0.5, // 枠線の太さ
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // 表示部分
                    children: [
                      const Icon(Icons.checklist, size: 20),
                      const SizedBox(width: 8),
                      Text(languageProvider.getLocalizedString('order')),  // 'order' の横に表示する
                      const SizedBox(width: 8),  // 少し間隔を空ける
                      Text(
                        totalPriceString,  // 総合計金額を表示
                        style: TextStyle(fontSize: 16),  // 太字にして、サイズ調整
                      ),
                    ],
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
            widget.menuItems[i].category = results[i]['category'];
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
                      updateCategories();
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
    BuildContext context, MenuItem menuItem) {
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
          if (!isFirstElementEmptyString(menuItem.imageUrls)) {
            totalImagesCount += menuItem.imageUrls!.length;
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
                              child: menuItem.isLoading
                                  ? Center( // 画像生成中のローディングインジケーター
                                      child: CircularProgressIndicator(),
                                    )
                                  : totalImagesCount == 0
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
                                            ? CachedNetworkImage(
                                                imageUrl: menuItem.imageUrls![currentImageIndex - 1], // 2枚目以降の画像
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()), // ロード中のインジケーター
                                                errorWidget: (context, url, error) => Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey[700],
                                                    size: 50,
                                                  ),
                                                ), // エラー時のアイコン
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
                              child: Container(
                                width: 40, // 幅を指定
                                height: 40, // 高さを指定
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4), // 半透明の白背景
                                  shape: BoxShape.circle, // 丸い背景
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back, color: Colors.black), // 黒い矢印アイコン
                                  onPressed: () {
                                    setState(() {
                                      currentImageIndex = (currentImageIndex + 1) % totalImagesCount;
                                    });
                                  },
                                ),
                              ),
                            ),
                          // 右矢印ボタン（Base64がない場合、imageUrlsがある場合に表示）
                          if (currentImageIndex < totalImagesCount - 1)
                            Positioned(
                              right: 5,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 40, // 幅を指定
                                height: 40, // 高さを指定
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4), // 半透明の白背景
                                  shape: BoxShape.circle, // 丸い背景
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward, color: Colors.black), // 黒い矢印アイコン
                                  onPressed: () {
                                    setState(() {
                                      currentImageIndex = (currentImageIndex + 1) % totalImagesCount;
                                    });
                                  },
                                ),
                              ),
                            ),
                          // 再生成ボタン（右下）
                          Positioned(
                            right: 0,
                            bottom: 0,
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
                                  // setState(() {
                                  //   menuItem.isLoading = true; // 画像生成開始時にisLoadingをtrueに設定
                                  // });

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
                                  // menuItem.isLoading = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center, // 縦方向の中央揃え
                      crossAxisAlignment: CrossAxisAlignment.center, // 横方向の中央揃え
                      children: [
                        Material(
                          color: Colors.transparent,  // 背景を透明に
                          child: InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(menuItem.menuEn)}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            splashColor: Colors.blue.withOpacity(0.2),  // クリック時のインクエフェクトの色
                            highlightColor: Colors.blue.withOpacity(0.1), // タップした時のハイライト色
                            child: RichText(
                              textAlign: TextAlign.center,  // テキストを中央揃え
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue,
                                  decorationThickness: 1.0,
                                ),
                                children: [
                                  TextSpan(
                                    text: menuItem.menuEn,  // 料理名のテキスト
                                  ),
                                  const TextSpan(
                                    text: " ", // テキストとアイコンの間にスペース
                                  ),
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.blue,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                    // 説明文表示
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                        Text(
                            menuItem.description,
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                    ),
                    const SizedBox(height: 5),
                    // 個数表示
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
                    const SizedBox(height: 5),
                    // 追加ボタン
                    ElevatedButton(
                      onPressed: () {
                        // 元のMenuItemのquantityを更新
                        menuItem.quantity = tempQuantity;

                        // Navigatorで画面を戻す
                        Navigator.of(context).pop();
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,  // フォントサイズを調整
                          ),
                          children: [
                            TextSpan(
                              text: '${Provider.of<LanguageProvider>(context).getLocalizedString('confirm')} ',
                            ),
                            TextSpan(
                              text: menuItem.price < 0 ? '¥-' : '¥${menuItem.price * tempQuantity}',
                            ),
                          ],
                        ),
                      ),
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