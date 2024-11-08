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

  @override
  Widget build(BuildContext context) {
    // 言語プロバイダーから現在の言語に基づいてローカライズされた文字列を取得
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getLocalizedString('order_history')), // 言語に基づいたタイトル
      ),
      body: orderHistory.isEmpty
          ? Center(child: Text(languageProvider.getLocalizedString('no_order_history')))  // 言語に基づいたメッセージ
          : ListView.builder(
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("${languageProvider.getLocalizedString('order')} #${index + 1}"), // 言語に基づいた注文番号
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: orderHistory[index].map((item) {
                        return Text(
                          "${item.menuJp} (${item.menuEn}) x${item.quantity}"
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
