import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:menu_app/models/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_app/providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<List<MenuItem>> orderHistory = [];
  final ImagePicker _picker = ImagePicker();
  Map<int, List<File?>> selectedImagesList = {};

  Future<void> _saveSelectedImages() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<String?>> paths = {};

    selectedImagesList.forEach((index, images) {
      paths[index.toString()] = images.map((image) => image?.path).toList();
    });

    await prefs.setString('selectedImagesList', jsonEncode(paths));
  }

  Future<void> _loadSelectedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagesData = prefs.getString('selectedImagesList');

    if (imagesData != null) {
      Map<String, dynamic> decodedData = jsonDecode(imagesData);
      Map<String, List<dynamic>> decodedPaths = decodedData.map((key, value) {
        return MapEntry(key, List<String?>.from(value));
      });

      setState(() {
        selectedImagesList = decodedPaths.map((index, paths) {
          return MapEntry(
            int.parse(index),
            paths.map((path) => path != null ? File(path) : null).toList(),
          );
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
    _loadSelectedImages(); // 画像パスの読み込み
  }

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

  Future<void> _pickImage(int orderIndex, int pictureIndex) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        // Ensure the list for the orderIndex is initialized
        selectedImagesList.putIfAbsent(orderIndex, () => [null, null, null]); // 最大3スロットに対応
        selectedImagesList[orderIndex]![pictureIndex] = File(image.path);
      });
      await _saveSelectedImages();  // パスを保存
    } else {
      // 画像が選ばれなかった場合は、スロットの追加をしない
      if (pictureIndex == (selectedImagesList[orderIndex]?.length ?? 3) - 1) {
        // 最後のスロットのタップ時に画像が選ばれなかった場合はスロットを追加しない
        return;
      }
    }
  }

  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      orderHistory = [];
      selectedImagesList.clear();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.getLocalizedString('delete_all_menus')),
          content: Text(languageProvider.getLocalizedString('delete_all_menus_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.getLocalizedString('cancel')),
            ),
            TextButton(
              onPressed: () async {
                await clearAllPreferences();
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.getLocalizedString('delete')),
            ),
          ],
        );
      },
    );
  }


  void _addNewImageSlot(int orderIndex) {
    setState(() {
      selectedImagesList.putIfAbsent(orderIndex, () => []);
      selectedImagesList[orderIndex]!.add(null);
    });
  }
  
Future<void> _launchGoogleMap(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication); // Opens in external browser or map app
  } else {
    throw 'Could not launch $url';
  }
}


  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getLocalizedString('order_history')),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteConfirmationDialog(context),
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
                      "${languageProvider.getLocalizedString('order')} #${index + 1}: ${orderHistory[index][0].shopName}",
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...orderHistory[index].map((item) {
                          return Text("${item.menuJp} (${item.menuEn}) x${item.quantity}");
                        }).toList(),
                        const SizedBox(height: 8),
                        // Updated to a horizontally scrollable image gallery
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedImagesList[index]?.length ?? 1,  // 画像数
                            itemBuilder: (context, pictureIndex) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (pictureIndex == (selectedImagesList[index]?.length ?? 3) - 1) {
                                      // 最後の画像をタップした場合に新しいスロットを追加
                                      _addNewImageSlot(index);
                                    }
                                    await _pickImage(index, pictureIndex);
                                  },
                                  child: SizedBox(
                                    width: 150,
                                    child: selectedImagesList[index] != null &&
                                            selectedImagesList[index]!.length > pictureIndex &&
                                            selectedImagesList[index]![pictureIndex] != null
                                        ? Image.file(
                                            selectedImagesList[index]![pictureIndex]!,
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.cover,
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_a_photo, size: 50, color: Colors.blue),
                                              Text('Upload Image', style: TextStyle(color: Colors.blue)),
                                            ],
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Google Mapの口コミボタン
                        Center(
                          child:ElevatedButton(
                                  onPressed: () 
                                  {
                                     _launchGoogleMap(orderHistory[index][0].shopUri);  
                                  },
                                  child: Text('Please post your Review.'),
                                )
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

