import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';  // JSONエンコード用
import 'package:menu_app/models/album.dart';

class DatabaseHelper {
  // シングルトンパターンでインスタンスを作成
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // データベースの初期化
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('albums.db');
    return _database!;
  }

  // データベースファイルを初期化
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // アルバムテーブルを作成するSQL文
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE albums (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      albumName TEXT,
      menuItems TEXT
    );
    ''');
  }

  // Albumをデータベースに保存する
  Future<void> insertAlbum(Album album) async {
    final db = await instance.database;

    // menuItemsはJSON形式で保存
    await db.insert(
      'albums',
      album.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // すべてのアルバムを取得
  Future<List<Album>> getAlbums() async {
    final db = await instance.database;
    final maps = await db.query('albums');

    if (maps.isNotEmpty) {
      return maps.map((map) => Album.fromMap(map)).toList();
    } else {
      return [];
    }
  }

  // IDでアルバムを取得
  Future<Album?> getAlbum(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'albums',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Album.fromMap(maps.first);
    } else {
      return null;
    }
  }
}
