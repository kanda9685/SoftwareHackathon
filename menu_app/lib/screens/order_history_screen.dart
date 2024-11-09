import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:menu_app/models/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:menu_app/providers/language_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<List<MenuItem>> orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  // 注文履歴をSharedPreferencesから読み込むメソッド
  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistoryJson = prefs.getStringList('orderHistory') ?? [];
    setState(() {
      orderHistory = orderHistoryJson.map((order) {
        List<dynamic> items = jsonDecode(order);
        return items.map((item) => MenuItem.fromJson(item)).toList();
      }).toList();
    });
  }

  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      orderHistory = []; // 表示されている履歴をクリア
    });
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
              onPressed: () async {
                await clearAllPreferences();
                Navigator.of(context).pop();
                setState(() {}); // 画面の更新
              },
              child: Text(languageProvider.getLocalizedString('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 言語プロバイダーから現在の言語に基づいてローカライズされた文字列を取得
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getLocalizedString('order_history')), // 言語に基づいたタイトル
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
body: orderHistory.isEmpty
    ? Center(child: Text(languageProvider.getLocalizedString('no_order_history')))
    : ListView.builder(
        itemCount: orderHistory.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                "${languageProvider.getLocalizedString('order')} #${index + 1}: ${orderHistory[index][0].shopName}"
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...orderHistory[index].map((item) {
                    return Text("${item.menuJp} (${item.menuEn}) x${item.quantity}");
                  }).toList(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Image.network(
                          'http://172.16.0.178:8000/uploaded_images/menu1/旬の魚の特製カルパッチョ/旬の魚の特製カルパッチョ_3.jpg',
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8), // 画像間のスペース
                      Expanded(
                        child: Image.network(
                          'http://172.16.0.178:8000/uploaded_images/menu1/旬の魚の特製カルパッチョ/旬の魚の特製カルパッチョ_2.jpg',
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final List<MenuItem> orderItems;

  const OrderDetailScreen({Key? key, required this.orderItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (context, index) {
          final item = orderItems[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("${item.menuJp} (${item.menuEn})"),
              subtitle: Text("Quantity: ${item.quantity}"),
            ),
          );
        },
      ),
    );
  }
}