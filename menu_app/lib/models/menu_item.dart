class MenuItem {
  final String menuJp;            // 日本語メニュー名
  String menuEn;                  // 英語メニュー名
  String description;             // 英語説明文
  List<String>? imageUrls;        // 画像URLのリスト (nullを許容)
  String base64Image;             // Base64形式の画像 (空文字をデフォルト)
  bool isBase64Image;             // 画像がBase64形式かどうかを判定するフラグ
  int quantity;                   // 選択した個数
  String selectedLanguage;        // 言語設定
  String shopName;                // 店名
  String category;                // カテゴリ (例: 'Main Dishes', 'Desserts' 等)

  // コンストラクタ
  MenuItem({
    required this.menuJp,
    required this.menuEn,
    required this.description,
    this.imageUrls,              
    this.base64Image = '',       // 空文字で初期化
    this.isBase64Image = false,  
    this.quantity = 0,
    this.selectedLanguage = 'English',
    this.shopName = '',
    required this.category,      // カテゴリを必須項目として追加
  });

  // JSONからMenuItemを生成するファクトリーメソッド
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuJp: json['menu_item'] as String? ?? '',  // nullなら空文字を代入
      menuEn: json['menu_en'] as String? ?? '',    // nullなら空文字を代入
      description: json['description'] as String? ?? '',  // nullなら空文字を代入
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>(), // 画像URLリスト（nullも許容）
      base64Image: json['base64_image'] as String? ?? '',  // Base64画像データがnullなら空文字を代入
      isBase64Image: json['is_base64_image'] as bool? ?? false, // Base64画像かどうかのフラグ（nullの場合はfalse）
      quantity: json['quantity'] as int? ?? 0,  // nullの場合は0を使用
      shopName: json['shop_name'] as String? ?? '',  // nullの場合は空文字
      category: json['category'] as String? ?? '',  // nullの場合は空文字
    );
  }

  // MenuItemをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuJp,
      'menu_en': menuEn,
      'description': description,
      'image_urls': imageUrls,
      'base64_image': base64Image,  // Base64形式の画像データ（追加）
      'is_base64_image': isBase64Image,  // Base64画像かどうかのフラグ（追加）
      'quantity': quantity,
      'shop_name': shopName,
      'category': category,  // カテゴリを追加
    };
  }

  // データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'menuJp': menuJp,
      'menuEn': menuEn,
      'description': description,
      'imageUrls': imageUrls,  // 画像URLリスト（nullも許容）
      'base64Image': base64Image,  // Base64画像データ（空文字でも許容）
      'isBase64Image': isBase64Image,  // Base64形式の画像かどうか
      'quantity': quantity,
      'shop_name': shopName,
      'category': category,  // カテゴリを追加
    };
  }

  // データベースからMapを使ってMenuItemを生成
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      menuJp: map['menuJp'] as String? ?? '',  // nullの場合は空文字
      menuEn: map['menuEn'] as String? ?? '',  // nullの場合は空文字
      description: map['description'] as String? ?? '',  // nullの場合は空文字
      imageUrls: (map['imageUrls'] as List<dynamic>?)?.cast<String>(),  // 画像URLリスト（nullも許容）
      base64Image: map['base64Image'] as String? ?? '',  // Base64画像データ（空文字でも許容）
      isBase64Image: map['isBase64Image'] as bool? ?? false, // Base64画像かどうかのフラグ
      quantity: map['quantity'] as int? ?? 0,  // nullの場合は0
      shopName: map['shop_name'] as String? ?? '',  // nullの場合は空文字
      category: map['category'] as String? ?? '',  // nullの場合は空文字
    );
  }
}
