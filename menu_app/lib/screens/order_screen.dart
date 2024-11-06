import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:menu_app/screens/album_creation_screen.dart';

class OrderScreen extends StatelessWidget {
  final List<MenuItem> selectedItems;

  const OrderScreen({Key? key, required this.selectedItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Order")), // 英語に変更
        body: const Center(
          child: Text(
            "No menu items selected. Please select items to order.", // 英語に変更
            style: TextStyle(fontSize: 16, color: Colors.black), // フォントカラーを黒に変更
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Order Summary")), // 英語に変更
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 注文内容と店員さんへのメッセージを一つのボックスにまとめて背景色を変える
            const AutoSizeText(
              "Please show this screen to the staff.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // フォントカラーを黒に変更
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 注文内容の表示（選択されたメニュー）
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, // 背景色を白に変更
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // メニューの前のメッセージ（日本語と英語を併記）
                  const Text(
                    "下記のメニューをお願いします。",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), // 日本語部分を太字に変更
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  const AutoSizeText(
                    "(Please select the following menu.)", // 英訳
                    style: TextStyle(fontSize: 14, color: Colors.black), // 少し小さく表示
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.grey, 
                    thickness: 1.5, // 横棒
                  ),
                  const SizedBox(height: 10),
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
                              style: const TextStyle(
                                fontSize: 16, 
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "${item.menuJp} ", // 日本語部分
                                  style: const TextStyle(fontWeight: FontWeight.bold), // 日本語部分のみ太字
                                ),
                                TextSpan(
                                  text: "(${item.menuEn})", // 英語部分
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 選択された個数
                        Text(
                          "x${item.quantity}", // メニューの数量を表示
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 注文確認ボタン
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // アルバム作成画面に遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AlbumCreationScreen(selectedItems: selectedItems)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
                  backgroundColor: Colors.green, // 完了ボタンに適した色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.check_circle, size: 24, color: Colors.white), // アイコン追加
                label: const Text(
                  "Order Completed", // 英語で注文確定ボタン
                  style: TextStyle(fontSize: 16, color: Colors.white), // ボタンの文字色を白に変更
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
