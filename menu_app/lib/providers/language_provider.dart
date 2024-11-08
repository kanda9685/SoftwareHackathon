import 'package:flutter/material.dart';
import 'dart:ui';

class LanguageProvider with ChangeNotifier {
  
  // プロパティを初期化
  String _selectedLanguage;

  // コンストラクタでset_languageを呼び出す
  LanguageProvider() : _selectedLanguage = _setLanguage();

  // 現在のロケールに応じて言語を設定
  static String _setLanguage() {
    Locale deviceLocale = window.locale;
    if (deviceLocale.languageCode == 'zh') {
      return "Chinese";
    } else if (deviceLocale.languageCode == 'ko') {
      return "Korean";
    } else {
      return "English";
    }
  }
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
      case 'Spanish':
        return 'Es';
      case 'French':
        return 'Fr';
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
      case 'Spanish':
        return 'Spanish';
      case 'French':
        return 'Franch';
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
      case 'Spanish':
        return _spanishStrings[key] ?? key;
      case 'French':
        return _frenchStrings[key] ?? key;
      default:
        return _englishStrings[key] ?? key;
    }
  }

  // 英語の文字列
  final Map<String, String> _englishStrings = {
    'menu': '\'s Menu',
    '_menu': 'Menu',
    'MenuBite' : 'MenuBite',
    'Lang' : 'Lang',
    'camera': 'Camera',
    'order_history': 'Order History',
    'Order_Phrase' : 'Order Phrase',
    'language': 'Language',
    'select_language': 'Select Language',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'loading': 'Loading...',
    'menu items': 'Menu Items',
    'show_to_staff': 'Please show this screen to the staff.',
    'I_would_like_to_order_the_dishes.': '(I would like to order the dishes.)',
    'order_completed': 'Order Completed',
    'no_order_history': 'No order history available.',
    'order': 'Order',
    'no_menu': 'No menus.',
    'thank_you': 'Thank you!',
    'image_uploaded': 'Your image has been uploaded successfully',
    'ok': 'OK',
    'error': 'Error',
    'failed_to_upload_image': 'Failed to upload image. Please try again.',
    'upload_image': 'Upload Image',
    'delete': 'Delete',
    'delete_all_menus': 'Delete All Menus',
    'delete_all_menus_confirmation': 'Are you sure you want to delete all menus?',
  };

  // 韓国語の文字列
  final Map<String, String> _koreanStrings = {
    'menu': ' 의 메뉴',
    '_menu': '메뉴',
    'MenuBite' : '메뉴바이트',
    'Lang' : '언어',
    'camera': '카메라',
    'order_history': '주문 내역',
    'Order_Phrase' : '주문 표현',
    'language': '언어',
    'select_language': '언어 선택',
    'cancel': '취소',
    'confirm': '확인',
    'loading': '로딩 중...',
    'menu items': '메뉴 항목',
    'show_to_staff': '직원에게 이 화면을 보여주세요.',
    'I_would_like_to_order_the_dishes.': '(이 요리를 주문하고 싶습니다.)',
    'order_completed': '주문 완료',
    'no_order_history': '주문 내역이 없습니다.',
    'order': '주문',
    'no_menu': '메뉴가 없습니다.',
    'thank_you': '감사합니다!',
    'image_uploaded': '이미지가 성공적으로 업로드되었습니다',
    'ok': '확인',
    'error': '오류',
    'failed_to_upload_image': '이미지 업로드 실패. 다시 시도해주세요.',
    'upload_image': '이미지 업로드',
    'delete': '삭제',
    'delete_all_menus': '모든 메뉴 삭제',
    'delete_all_menus_confirmation': '모든 메뉴를 삭제하시겠습니까?',
  };

  // 中国語の文字列
  final Map<String, String> _chineseStrings = {
    'menu': '的菜单',
    '_menu': '菜单',
    'MenuBite' : '菜单点',
    'Lang' : '语',
    'camera': '相机',
    'order_history': '订单历史',
    'Order_Phrase' : '点单用语',
    'language': '语言',
    'select_language': '选择语言',
    'cancel': '取消',
    'confirm': '确认',
    'loading': '加载中...',
    'menu items': '菜单项',
    'show_to_staff': '请向工作人员出示此屏幕。',
    'I_would_like_to_order_the_dishes.': '(我想点这些菜。)',
    'order_completed': '订单完成',
    'no_order_history': '没有订单历史记录。',
    'order': '订单',
    'no_menu': '没有菜单。',
    'thank_you': '谢谢！',
    'image_uploaded': '您的图片已成功上传',
    'ok': '确定',
    'error': '错误',
    'failed_to_upload_image': '图片上传失败，请重试。',
    'upload_image': '上传图片',
    'delete': '删除',
    'delete_all_menus': '删除所有菜单',
    'delete_all_menus_confirmation': '您确定要删除所有菜单吗？',
  };

  // スペイン語の文字列
  final Map<String, String> _spanishStrings = {
    'menu': 'Menú de ',
    '_menu' : 'Menú',
    'MenuBite' : 'BocadoDeMenú',
    'Lang' : 'Idioma',
    'camera': 'Cámara',
    'order_history': 'Historial de pedidos',
    'Order_Phrase' : 'Frase de Pedido',
    'language': 'Idioma',
    'select_language': 'Seleccionar idioma',
    'cancel': 'Cancelar',
    'confirm': 'Confirmar',
    'loading': 'Cargando...',
    'menu items': 'Artículos del menú',
    'show_to_staff': 'Por favor, muestre esta pantalla al personal.',
    'I_would_like_to_order_the_dishes.': '(Me gustaría ordenar los platos.)',
    'order_completed': 'Pedido completado',
    'no_order_history': 'No hay historial de pedidos.',
    'order': 'Pedido',
    'no_menu': 'No hay menús.',
    'thank_you': '¡Gracias!',
    'image_uploaded': 'Tu imagen se ha subido correctamente',
    'ok': 'OK',
    'error': 'Error',
    'failed_to_upload_image': 'Error al subir la imagen. Inténtalo de nuevo.',
    'upload_image': 'Subir imagen',
    'delete': 'Eliminar',
    'delete_all_menus': 'Eliminar todos los menús',
    'delete_all_menus_confirmation': '¿Está seguro de que desea eliminar todos los menús?',
  };

  // フランス語の文字列
  final Map<String, String> _frenchStrings = {
    'menu': 'Menu de ',
    '_menu': 'Menu',
    'MenuBite' : 'MenuMorceau',
    'Lang' : 'Lang',
    'camera': 'Caméra',
    'order_history': 'Historique des commandes',
    'Order_Phrase' : 'Phrase de Commande',
    'language': 'Langue',
    'select_language': 'Sélectionner la langue',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'loading': 'Chargement...',
    'menu items': 'Articles du menu',
    'show_to_staff': 'Veuillez montrer cet écran au personnel.',
    'I_would_like_to_order_the_dishes.': '(Je voudrais commander les plats.)',
    'order_completed': 'Commande terminée',
    'no_order_history': 'Aucun historique de commandes.',
    'order': 'Commander',
    'no_menu': 'Aucun menu.',
    'thank_you': 'Merci!',
    'image_uploaded': 'Votre image a été téléchargée avec succès',
    'ok': 'OK',
    'error': 'Erreur',
    'failed_to_upload_image': 'Échec du téléchargement de l\'image. Veuillez réessayer.',
    'upload_image': 'Télécharger l\'image',
    'delete': 'Supprimer',
    'delete_all_menus': 'Supprimer tous les menus',
    'delete_all_menus_confirmation': 'Êtes-vous sûr de vouloir supprimer tous les menus ?',
  };
}
