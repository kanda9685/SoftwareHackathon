import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:menu_app/screens/order_screen.dart';

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
    if (widget.menuItems.isEmpty) {
      return const Center(child: Text("No menus."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          // ゴミ箱アイコンの追加
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _showDeleteConfirmationDialog(context); // ゴミ箱アイコンがタップされたときに確認ダイアログを表示
            },
          ),
        ],
      ),
      body: Column(
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
                              child: menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      child: Image.network(
                                        menuItem.imageUrl!,
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

  void _showMenuItemDialog(BuildContext context, MenuItem menuItem, Function(MenuItem) onQuantityUpdated) {
    // 一時的な変数を作成して、quantityを管理
    int tempQuantity = menuItem.quantity;

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
                        // 画像領域
                        Container(
                          width: double.infinity,
                          height: 250.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty
                                ? Image.network(
                                    menuItem.imageUrl!,
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
                                : Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[700],
                                      size: 50,
                                    ),
                                  ),
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
                                    tempQuantity--; // 表示用の一時的なquantityを減少
                                  }
                                });
                              },
                            ),
                            Text('$tempQuantity', style: const TextStyle(fontSize: 18, color: Colors.black)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  if (tempQuantity < 10) { // 最大個数の制限
                                    tempQuantity++; // 表示用の一時的なquantityを増加
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 追加ボタン
                        ElevatedButton(
                          onPressed: () {
                            // ダイアログを閉じて、親ウィジェットに更新されたMenuItemを返す
                            onQuantityUpdated(MenuItem(
                              menuJp: menuItem.menuJp,
                              menuEn: menuItem.menuEn,
                              description: menuItem.description,
                              imageUrl: menuItem.imageUrl,
                              quantity: tempQuantity,
                            ));
                            Navigator.of(context).pop();
                          },
                          child: const Text('Confirm'),
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
                        padding: const EdgeInsets.all(6.0), // ボタン周りに余白を追加
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6), // バツボタンの背景色を暗く
                          shape: BoxShape.circle, // 丸型にする
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white, // バツボタンの色を白に
                          size: 24.0, // バツボタンのサイズ
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
