// lib/providers/language_provider.dart
import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'English';

  String get selectedLanguage => _selectedLanguage;

  void updateLanguage(String language) {
    if (_selectedLanguage != language) {
      _selectedLanguage = language;
      notifyListeners();  // 言語変更を通知
    }
  }
}
