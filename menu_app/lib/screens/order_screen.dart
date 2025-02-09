import 'package:flutter/material.dart';
import 'package:menu_app/main.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:menu_app/screens/order_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart'; // Make sure this import is added
import 'package:provider/provider.dart';
import 'package:menu_app/providers/language_provider.dart';
import 'package:menu_app/providers/menu_items_provider.dart';
import 'package:menu_app/providers/camera_provider.dart'; 

class OrderScreen extends StatelessWidget {
  final List<MenuItem> selectedItems;

  const OrderScreen({Key? key, required this.selectedItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access LanguageProvider

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getLocalizedString('Order_Phrase')),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // 横線の高さを指定
            child: Container(
              color: Colors.grey, // 横線の色を指定
              height: 0.5, // 横線の太さを指定
            ),
          ),
      ), // Use localized string
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 注文内容と店員さんへのメッセージを一つのボックスにまとめて背景色を変える
            AutoSizeText(
              languageProvider.getLocalizedString('show_to_staff'), // Localized string
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 注文内容の表示（選択されたメニュー）
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // メニューリストの表示（英語と日本語を併記）
                  ...selectedItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // メニュー名（日本語のみ太字に変更）
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              children: [
                                TextSpan(
                                  text: "${item.menuJp} ", // Japanese part
                                  style: TextStyle(fontWeight: FontWeight.bold), // Bold Japanese part
                                ),
                                TextSpan(
                                  text: "(${item.menuEn})", // English part
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Selected quantity
                        Text(
                          "x${item.quantity}",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {

                  Provider.of<MenuItemsProvider>(context, listen: false).resetQuantities();

                  // Close current screen and go back
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(
                        camera: Provider.of<CameraProvider>(context).camera,
                        selectedIndex: 1,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.check_circle, size: 24, color: Colors.white),
                label: Text(languageProvider.getLocalizedString('order_completed'), style: TextStyle(fontSize: 16, color: Colors.white)), // Localized string
              ),
            ),
          ],
        ),
      ),
    );
  }
}
