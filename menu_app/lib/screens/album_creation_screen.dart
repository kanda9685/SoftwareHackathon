import 'package:flutter/material.dart';
import 'package:menu_app/models/menu_item.dart';
import 'package:menu_app/models/album.dart';  // Albumモデルをインポート
import 'package:menu_app/helpers/database_helper.dart';  // データベース操作用のヘルパークラス（後述）

class AlbumCreationScreen extends StatelessWidget {
  final List<MenuItem> selectedItems;

  AlbumCreationScreen({Key? key, required this.selectedItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Album")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メニュー項目の表示
            const Text(
              "Are you sure you want to create an album with the following menu items?",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              children: selectedItems.map((item) {
                return ListTile(
                  title: Text("${item.menuEn} (${item.menuJp})"),
                  subtitle: Text("x${item.quantity}"),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // アルバム作成確認ボタン（作成する、しない）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 「アルバム作成しない」ボタン
                ElevatedButton.icon(
                  onPressed: () {
                    // メニュー情報を削除してホーム画面に戻る
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,  // Correct parameter
                  ),
                ),
                const SizedBox(width: 20),
                // 「アルバム作成する」ボタン
                ElevatedButton.icon(
                  onPressed: () async {
                    // アルバム作成処理
                    final album = Album(
                      albumName: "New Album",  // 任意のアルバム名を設定
                      menuItems: selectedItems,
                    );

                    // アルバムをデータベースに保存
                    await DatabaseHelper.instance.insertAlbum(album);

                    // アルバム作成後、アルバム一覧画面へ遷移
                    Navigator.pushReplacementNamed(context, '/albumList');
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Create Album"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,  // Correct parameter
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
