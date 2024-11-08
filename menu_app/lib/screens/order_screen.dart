import 'package:flutter/material.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:menu_app/providers/camera_provider.dart';
import 'package:menu_app/main.dart';


class OrderScreen extends StatelessWidget {
  final List<MenuItem> selectedItems;

  const OrderScreen({Key? key, required this.selectedItems}) : super(key: key);

  Future<void> _saveOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistory = prefs.getStringList('orderHistory') ?? [];
    String newOrder = jsonEncode(selectedItems.map((item) => item.toJson()).toList());
    orderHistory.add(newOrder);
    await prefs.setStringList('orderHistory', orderHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 注文内容と店員さんへのメッセージ
            const Text(
              "Please show this screen to the staff.",
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
                  const Text(
                    "Selected Menu Items",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // メニューリストの表示
                  ...selectedItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.menuJp} (${item.menuEn})",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text("x${item.quantity}", style: const TextStyle(fontSize: 14)),
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
                  await _saveOrderHistory();  // 注文データを保存

                  // CameraProvider インスタンスを取得
                  final cameraProvider = Provider.of<CameraProvider>(context, listen: false);

                  // 現在の画面を閉じてから、カメラページへ遷移
                  Navigator.pop(context); // 現在のページを閉じる (一つ戻る)
                  
                  // 新しい画面 (カメラページ) へ遷移
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(camera: cameraProvider.camera),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle, size: 24, color: Colors.white),
                label: const Text("Order Completed", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
