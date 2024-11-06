class MenuItem {
  final String menuJp;  // 日本語メニュー名
  final String menuEn;    // 英語メニュー名
  final String description;    // 英語説明文

  // コンストラクタ
  MenuItem({
    required this.menuJp,
    required this.menuEn,
    required this.description,
  });

  // JSONからMenuItemを生成するファクトリーメソッド
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuJp: json['menu_item'] as String,
      menuEn: json['menu_en'] as String,
      description: json['description'] as String,
    );
  }
}