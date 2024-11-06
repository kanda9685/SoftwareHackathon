class MenuItem {
  final String menuJp;         // 日本語メニュー名
  final String menuEn;         // 英語メニュー名
  final String description;    // 英語説明文
  final String? imageUrl;      // 画像URL (nullを許容)
  bool isSelected;             // 選択状態

  // コンストラクタ
  MenuItem({
    required this.menuJp,
    required this.menuEn,
    required this.description,
    this.imageUrl,             // nullを許容
    this.isSelected = false,   // 初期値は未選択
  });

  // JSONからMenuItemを生成するファクトリーメソッド
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuJp: json['menu_item'] as String,
      menuEn: json['menu_en'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,    // nullを許容
    );
  }
}