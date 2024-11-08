import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'English'; // 初期設定はEnglish

  String get selectedLanguage => _selectedLanguage;

  void updateLanguage(String newLanguage) {
    if (_selectedLanguage != newLanguage) {
      _selectedLanguage = newLanguage;
      notifyListeners(); // 言語変更を通知してUI更新
    }
  }

  // 言語に応じた省略形を返す
  String getLanguageShortCode() {
    switch (_selectedLanguage) {
      case 'English':
        return 'En';
      case 'Korean':
        return 'Ko';
      case 'Chinese':
        return 'Zh';
      default:
        return 'En';
    }
  }

  // 言語に応じたフルネームを返す
  String getLanguageFullName(String language) {
    switch (language) {
      case 'English':
        return 'English';
      case 'Korean':
        return 'Korean';
      case 'Chinese':
        return 'Chinese';
      default:
        return 'English';
    }
  }

  // 言語ごとの文字列を返すメソッド
  String getLocalizedString(String key) {
    switch (_selectedLanguage) {
      case 'English':
        return _englishStrings[key] ?? key;
      case 'Korean':
        return _koreanStrings[key] ?? key;
      case 'Chinese':
        return _chineseStrings[key] ?? key;
      default:
        return _englishStrings[key] ?? key;
    }
  }

  // 英語の文字列
  final Map<String, String> _englishStrings = {
    'menu': 'Menu',
    'camera': 'Camera',
    'order_history': 'Order History',
    'language': 'Language',
    'select_language': 'Select Language',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'loading': 'Loading...',
    'menu_items': 'Menu Items',  // 追加
    'lang': 'Lang',              // 追加
  };

  // 韓国語の文字列
  final Map<String, String> _koreanStrings = {
    'menu': '메뉴',
    'camera': '카메라',
    'order_history': '주문 내역',
    'language': '언어',
    'select_language': '언어 선택',
    'cancel': '취소',
    'confirm': '확인',
    'loading': '로딩 중...',
    'menu_items': '메뉴 항목',  // 追加
    'lang': '언어',            // 追加
  };

  // 中国語の文字列
  final Map<String, String> _chineseStrings = {
    'menu': '菜单',
    'camera': '相机',
    'order_history': '订单历史',
    'language': '语言',
    'select_language': '选择语言',
    'cancel': '取消',
    'confirm': '确认',
    'loading': '加载中...',
    'menu_items': '菜单项',  // 追加
    'lang': '语言',          // 追加
  };
}
