class MenuItem {
  final String menuJp;         // 日本語メニュー名
  final String menuEn;         // 英語メニュー名
  final String description;    // 英語説明文
  final String? imageUrl;      // 画像URL (nullを許容)
  int quantity;                // 選択した個数

  // コンストラクタ
  MenuItem({
    required this.menuJp,
    required this.menuEn,
    required this.description,
    this.imageUrl,             // nullを許容
    this.quantity = 0,         // 初期値は0（選択なし）
  });

  // JSONからMenuItemを生成するファクトリーメソッド
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuJp: json['menu_item'] as String,
      menuEn: json['menu_en'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,    // nullを許容
      quantity: json['quantity'] ?? 0,           // quantityをJSONから取得（デフォルトは0）
    );
  }

  // MenuItemをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'menuJp': menuJp,
      'menuEn': menuEn,
      'quantity': quantity,
    };
  }

  // データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'menuJp': menuJp,
      'menuEn': menuEn,
      'description': description,
      'imageUrl': imageUrl,    // 画像URL（nullも許容）
      'quantity': quantity,
    };
  }

  // データベースからMapを使ってMenuItemを生成
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      menuJp: map['menuJp'] as String,
      menuEn: map['menuEn'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String?,  // 画像URL（nullも許容）
      quantity: map['quantity'] as int,
    );
  }
}
