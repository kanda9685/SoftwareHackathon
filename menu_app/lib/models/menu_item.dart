class MenuItem {
  final String menuJp;
  String menuEn;
  String description;
  List<String>? imageUrls;
  String base64Image;
  bool isBase64Image;
  bool isLoading; // 画像生成中かどうかを示すフラグ
  int quantity;
  String selectedLanguage;
  String shopName;
  String shopUri;
  String category;
  int price;

  // コンストラクタ
  MenuItem({
    required this.menuJp,
    required this.menuEn,
    required this.description,
    this.imageUrls,
    this.base64Image = '',
    this.isBase64Image = false,
    this.isLoading = false, // 初期状態では生成中ではない
    this.quantity = 0,
    this.selectedLanguage = 'English',
    this.shopName = '',
    this.shopUri = '',
    required this.category,
    this.price = 0,  // 価格が初期化されている
  });

  // JSONからMenuItemを生成するファクトリーメソッド
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuJp: json['menu_item'] as String? ?? '',
      menuEn: json['menu_en'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>(),
      base64Image: json['base64_image'] as String? ?? '',
      isBase64Image: json['is_base64_image'] as bool? ?? false,
      isLoading: json['is_loading'] as bool? ?? false, // isLoadingの値も反映
      quantity: json['quantity'] as int? ?? 0,
      shopName: json['shop_name'] as String? ?? '',
      shopUri: json['shop_uri'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: json['price'] as int? ?? 0,  // JSONで価格を受け取る
    );
  }

  // MenuItemをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuJp,
      'menu_en': menuEn,
      'description': description,
      'image_urls': imageUrls,
      'base64_image': base64Image,
      'is_base64_image': isBase64Image,
      'is_loading': isLoading, // isLoadingを保存
      'quantity': quantity,
      'shop_name': shopName,
      'shop_uri': shopUri,
      'category': category,
      'price': price, // 価格を保存
    };
  }

  // データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'menuJp': menuJp,
      'menuEn': menuEn,
      'description': description,
      'imageUrls': imageUrls,
      'base64Image': base64Image,
      'isBase64Image': isBase64Image,
      'isLoading': isLoading, // isLoadingを追加
      'quantity': quantity,
      'shop_name': shopName,
      'shop_uri': shopUri,
      'category': category,
      'price': price,  // 価格を保存
    };
  }

  // データベースからMapを使ってMenuItemを生成
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      menuJp: map['menuJp'] as String? ?? '',
      menuEn: map['menuEn'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrls: (map['imageUrls'] as List<dynamic>?)?.cast<String>(),
      base64Image: map['base64Image'] as String? ?? '',
      isBase64Image: map['isBase64Image'] as bool? ?? false,
      isLoading: map['isLoading'] as bool? ?? false, // isLoadingをMapから受け取る
      quantity: map['quantity'] as int? ?? 0,
      shopName: map['shop_name'] as String? ?? '',
      shopUri: map['shop_uri'] as String? ?? '',
      category: map['category'] as String? ?? '',
      price: map['price'] as int? ?? 0,  // 価格をMapから受け取る
    );
  }
}
