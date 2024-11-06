import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:menu_app/models/menu_item.dart';

class MenuGridScreen extends StatelessWidget {
  final List<MenuItem> menuItems; 

  const MenuGridScreen({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    // メニューアイテムがない場合は何も表示しない
    if (menuItems.isEmpty) {
      return const Center(child: Text("メニューはありません"));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final menuItem = menuItems[index];
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
                        menuItem.menuJp,
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
                        menuItem.menuEn,
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
