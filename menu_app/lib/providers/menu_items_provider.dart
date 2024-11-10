// menu_items_provider.dart
import 'package:flutter/material.dart';
import 'package:menu_app/models/menu_item.dart';

class MenuItemsProvider with ChangeNotifier {
  List<MenuItem> _menuItems = [];

  List<MenuItem> get menuItems => _menuItems;

  void setMenuItems(List<MenuItem> items) {
    _menuItems = items;
    notifyListeners();
  }

  void addMenuItem(MenuItem item) {
    _menuItems.add(item);
    notifyListeners();
  }

    // 全てのMenuItemのquantityを0にする処理
  void resetQuantities() {
    for (var item in _menuItems) {
      item.quantity = 0; // quantityを0に設定
    }
    notifyListeners(); // 変更をリスナーに通知
  }
}
