import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:menu_app/models/menu_item.dart';

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

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: widget.menuItems.length,
      itemBuilder: (context, index) {
        final menuItem = widget.menuItems[index];

        return GestureDetector(
          onTap: () {
            _showMenuItemDialog(context, menuItem);
          },
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: menuItem.isSelected
                  ? Colors.lightGreenAccent[100] // 選択済みの背景色
                  : Colors.grey[200],            // 未選択の背景色
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 画像部分 (上側は丸く、下側は直線)
                Container(
                  width: double.infinity,
                  height: 120,  // 高さを固定して余白を防ぐ
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),  // 上左の角を丸く
                      topRight: Radius.circular(10), // 上右の角を丸く
                    ),
                  ),
                  child: menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
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
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.image,
                          color: Colors.grey[700],
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
                // 選択ボタン部分
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: menuItem.isSelected
                          ? Colors.redAccent
                          : Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(menuItem.isSelected
                        ? Icons.cancel
                        : Icons.check_circle),
                    label: Text(menuItem.isSelected ? "Deselect" : "Select"),
                    onPressed: () {
                      setState(() {
                        menuItem.isSelected = !menuItem.isSelected;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMenuItemDialog(BuildContext context, MenuItem menuItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Container(
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
                // 横並びのボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 戻るボタン
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    // 選択/選択解除ボタン
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: menuItem.isSelected
                            ? Colors.redAccent
                            : Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(menuItem.isSelected
                          ? Icons.cancel
                          : Icons.check_circle),
                      label: Text(menuItem.isSelected ? "Deselect" : "Select"),
                      onPressed: () {
                        // isSelectedを反転し、UIを更新
                        setState(() {
                          menuItem.isSelected = !menuItem.isSelected;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
