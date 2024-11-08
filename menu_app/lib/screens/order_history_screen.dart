import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:menu_app/models/menu_item.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      body: orderHistory.isEmpty
          ? const Center(child: Text("No order history available."))
          : ListView.builder(
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("Order #${index + 1}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: orderHistory[index].map((item) {
                        return Text("${item.menuJp} (${item.menuEn}) x${item.quantity}");
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
