class MenuItem {
  final String menuJp;           // 日本語メニュー名
  String menuEn;           // 英語メニュー名
  String description;      // 英語説明文
  List<String>? imageUrls; // 画像URLのリスト (nullを許容)
  int quantity;                  // 選択した個数
  String selectedLanguage; // 言語設定
  String shopName; //店名

  // コンストラクタ
  MenuItem({
    required this.menuJp,
    required this.menuEn,
    required this.description,
    this.imageUrls,               // nullを許容
    this.quantity = 0,            // 初期値は0（選択なし）
    this.selectedLanguage = 'English', 
    this.shopName='',
  });

  // JSONからMenuItemを生成するファクトリーメソッド
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuJp: json['menu_item'] as String,
      menuEn: json['menu_en'] as String,
      description: json['description'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>(), // 複数画像に対応
      quantity: json['quantity'] ?? 0,                                  // quantityをJSONから取得（デフォルトは0）
      shopName: json['shop_name'] as String? ?? '', // nullの場合は空文字
    );
  }

  // MenuItemをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuJp,
      'menu_en': menuEn,
      'description': description,
      'image_urls': imageUrls,
      'quantity': quantity,
      'shop_name' :shopName,
    };
  }

  // データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'menuJp': menuJp,
      'menuEn': menuEn,
      'description': description,
      'imageUrls': imageUrls,  // 画像URLリスト（nullも許容）
      'quantity': quantity,
      'shop_name' :shopName,
    };
  }

  // データベースからMapを使ってMenuItemを生成
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      menuJp: map['menuJp'] as String,
      menuEn: map['menuEn'] as String,
      description: map['description'] as String,
      imageUrls: (map['imageUrls'] as List<dynamic>?)?.cast<String>(),  // 画像URLリスト（nullも許容）
      quantity: map['quantity'] as int? ?? 0,
      shopName: map['shop_name'] as String? ?? '',
    );
  }
}
