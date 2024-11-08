import 'package:menu_app/models/menu_item.dart';

class User {
  final String id;              // ユーザーID (例: UUID)
  final String username;         // ユーザー名
  String email;                  // メールアドレス
  String password;               // パスワード（ハッシュ化推奨）
  List<MenuItem> menuItems;      // ユーザーに関連するメニューアイテムのリスト

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.menuItems = const [],    // 初期値は空のリスト
  });

  // JSONからUserを生成するファクトリーメソッド
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      menuItems: (json['menuItems'] as List<dynamic>?)
              ?.map((item) => MenuItem.fromJson(item))
              .toList() ??
          [], // nullチェック
    );
  }

  // UserをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'menuItems': menuItems.map((item) => item.toJson()).toList(),
    };
  }
}
