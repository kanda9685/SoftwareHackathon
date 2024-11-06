import 'dart:convert';
import 'menu_item.dart';

class Album {
  final String albumName;
  final List<MenuItem> menuItems;

  Album({required this.albumName, required this.menuItems});

  // toMapメソッドでmenuItemsをJSON文字列に変換
  Map<String, dynamic> toMap() {
    return {
      'albumName': albumName,
      'menuItems': json.encode(menuItems.map((item) => item.toMap()).toList()), // MenuItemをJSON形式に変換
    };
  }

  // fromMapメソッドでmenuItemsをデコードしてList<MenuItem>に戻す
  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      albumName: map['albumName'],
      menuItems: List<MenuItem>.from(
        json.decode(map['menuItems']).map((item) => MenuItem.fromMap(item)),
      ),
    );
  }
}