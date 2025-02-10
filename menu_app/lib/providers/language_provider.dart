import 'package:flutter/material.dart';
import 'dart:ui';

class LanguageProvider with ChangeNotifier {
  
  // プロパティを初期化
  String _selectedLanguage;

  // コンストラクタでset_languageを呼び出す
  LanguageProvider() : _selectedLanguage = _setLanguage();

  // デバイスのロケールに応じて言語を設定
  static String _setLanguage() {
    Locale deviceLocale = window.locale;
    
    if (deviceLocale.languageCode == 'ja') {
      return "Japanese";
    } else if (deviceLocale.languageCode == 'zh') {
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
      case 'Japanese':
        return 'Ja';
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
      case 'German':
        return 'De';
      case 'Portuguese':
        return 'Pt';
      case 'Russian':
        return 'Ru';
      case 'Arabic':
        return 'Ar';
      case 'Hindi':
        return 'Hi';
      case 'Italian':
        return 'It';
      default:
        return 'En';
    }
  }

  // 言語に応じたフルネームを返す
  String getLanguageFullName(String language) {
    switch (language) {
      case 'Japanese':
        return 'Japanese';
      case 'English':
        return 'English';
      case 'Korean':
        return 'Korean';
      case 'Chinese':
        return 'Chinese';
      case 'Spanish':
        return 'Spanish';
      case 'French':
        return 'French';
      case 'German':
        return 'German';
      case 'Portuguese':
        return 'Portuguese';
      case 'Russian':
        return 'Russian';
      case 'Arabic':
        return 'Arabic';
      case 'Hindi':
        return 'Hindi';
      case 'Italian':
        return 'Italian';
      default:
        return 'English';
    }
  }

  // 言語に応じた店名と「menu」の順番を決定するメソッド
  String getMenuTitleOrder() {
    switch (_selectedLanguage) {
      case 'Japanese':
      case 'English':
      case 'Korean':
      case 'Chinese':
        return 'front';
      case 'Spanish':
      case 'French':
      case 'German':
      case 'Portuguese':
      case 'Russian':
      case 'Arabic':
      case 'Hindi':
      case 'Italian':
        return 'back';
      default:
        return 'front';
    }
  }

  // 言語ごとの文字列を返すメソッド
  String getLocalizedString(String key) {
    switch (_selectedLanguage) {
      case 'Japanese':
        return _japaneseStrings[key] ?? key;
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
      case 'German':
        return _germanStrings[key] ?? key;
      case 'Portuguese':
        return _portugueseStrings[key] ?? key;
      case 'Russian':
        return _russianStrings[key] ?? key;
      case 'Arabic':
        return _arabicStrings[key] ?? key;
      case 'Hindi':
        return _hindiStrings[key] ?? key;
      case 'Italian':
        return _italianStrings[key] ?? key;
      default:
        return _englishStrings[key] ?? key;
    }
  }

  // 日本語の文字列
  final Map<String, String> _japaneseStrings = {
    'menu': 'のメニュー',
    '_menu': 'メニュー画面',
    'MenuBite' : 'MenuBite',
    'Lang' : '言語',
    'camera': 'カメラ',
    'order_history': '注文履歴',
    'Order_Phrase' : '注文画面',
    'language': '言語',
    'select_language': '言語選択',
    'cancel': 'キャンセル',
    'confirm': '確認',
    'loading': '読み込み中...',
    'menu items': 'メニュー',
    'show_to_staff': 'この画面を店員に見せてください。',
    'I_would_like_to_order_the_dishes.': '(私はこの料理を注文したいです。)',
    'order_completed': '注文完了',
    'no_order_history': '注文履歴はありません。',
    'order': '注文',
    'no_menu': 'メニューはありません。',
    'thank_you': 'ありがとうございます!',
    'image_uploaded': '写真が送信されました。',
    'ok': '了解',
    'error': 'エラー',
    'failed_to_upload_image': '送信に失敗しました。もう一度お試しください。',
    'upload_image': '写真の送信',
    'delete': '削除する',
    'delete_all_menus': 'メニューの削除',
    'delete_all_menus_confirmation': 'すべてのメニューを削除しますか？',
    'Sorry.':'申し訳ありません。',
    'Faildish':'料理が見つかりませんでした。もう一度お試しください。',
    'Preview' : 'プレビュー',
    'dontdelete': '削除しない',
    'delete_all_menus_forlang': '既に存在するメニューをすべて削除しますか？',
    'generating': 'AI画像を生成しています...',
  };

  // 英語の文字列
  final Map<String, String> _englishStrings = {
    'menu': '\'s Menu',
    '_menu': 'Menu',
    'MenuBite' : 'MenuBite',
    'Lang' : 'Lang',
    'camera': 'Camera',
    'order_history': 'Order History',
    'Order_Phrase' : 'Order Screen',
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
    'Sorry.':'Sorry.',
    'Faildish':'Failed to find any dishes. Please try again.',
    'Preview' : 'Preview',
    'dontdelete': 'Not delete',
    'delete_all_menus_forlang': 'Would you like to delete the menu exists already?',
    'generating': 'Generating image with AI...',
  };

  // 韓国語の文字列
  final Map<String, String> _koreanStrings = {
    'menu': ' 의 메뉴',
    '_menu': '메뉴',
    'MenuBite' : '메뉴바이트',
    'Lang' : '언어',
    'camera': '카메라',
    'order_history': '주문 내역',
    'Order_Phrase' : '주문 화면',
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
    'Sorry.':'죄송합니다.',
    'Faildish':'음식을 찾을 수 없습니다. 다시 시도해 주세요.',
    'Preview' : '미리보기',
    'dontdelete': '삭제하지 않음',
    'delete_all_menus_forlang': '이미 존재하는 메뉴를 삭제하시겠습니까?',
    'generating': 'AI로 이미지 생성 중',
  };

  // 中国語の文字列
  final Map<String, String> _chineseStrings = {
    'menu': '的菜单',
    '_menu': '菜单',
    'MenuBite' : '菜单点',
    'Lang' : '语',
    'camera': '相机',
    'order_history': '订单历史',
    'Order_Phrase' : '订单页面',
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
    'Sorry.':'对不起。',
    'Faildish':'未能找到任何菜肴，请再试一次。',
    'Preview' : '预览',
    'dontdelete': '不删除',
    'delete_all_menus_forlang': '您想删除已经存在的菜单吗？',
    'generating': 'AI正在生成图像', 
  };

  // スペイン語の文字列
  final Map<String, String> _spanishStrings = {
    'menu': 'Menú de ',
    '_menu' : 'Menú',
    'MenuBite' : 'BocadoDeMenú',
    'Lang' : 'Idioma',
    'camera': 'Cámara',
    'order_history': 'Historial de pedidos',
    'Order_Phrase' : 'Pantalla de pedido',
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
    'Sorry.':'Lo siento.',
    'Faildish':'No se encontraron platos. Por favor, inténtalo de nuevo.',
    'Preview' : 'Vista previa',
    'dontdelete': 'No eliminar',
    'delete_all_menus_forlang': '¿Le gustaría eliminar el menú que ya existe?',
    'generating': 'Generando imagen con IA',
  };

  // フランス語の文字列
  final Map<String, String> _frenchStrings = {
    'menu': 'Menu de ',
    '_menu': 'Menu',
    'MenuBite' : 'MenuMorceau',
    'Lang' : 'Lang',
    'camera': 'Caméra',
    'order_history': 'Historique des commandes',
    'Order_Phrase' : 'Écran de commande',
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
    'Sorry.':'Désolé',
    'Faildish':'Impossible de trouver des plats. Veuillez réessayer.',
    'Preview' : 'Aperçu',
    'dontdelete': 'Ne pas supprimer',
    'delete_all_menus_forlang': 'Souhaitez-vous supprimer le menu qui existe déjà ?',
    'generating': 'Génération d\'image par IA', 
  };

  // German (Deutsch)
  final Map<String, String> _germanStrings = {
    'menu': 'Menü von',
    '_menu': 'Menü-Bildschirm',
    'MenuBite': 'MenuBite',
    'Lang': 'Sprache',
    'camera': 'Kamera',
    'order_history': 'Bestellverlauf',
    'Order_Phrase': 'Bestellbildschirm',
    'language': 'Sprache',
    'select_language': 'Sprache wählen',
    'cancel': 'Abbrechen',
    'confirm': 'Bestätigen',
    'loading': 'Laden...',
    'menu items': 'Menüpunkte',
    'show_to_staff': 'Bitte zeigen Sie diesen Bildschirm dem Personal.',
    'I_would_like_to_order_the_dishes.': '(Ich möchte diese Gerichte bestellen.)',
    'order_completed': 'Bestellung abgeschlossen',
    'no_order_history': 'Keine Bestellhistorie.',
    'order': 'Bestellung',
    'no_menu': 'Kein Menü vorhanden.',
    'thank_you': 'Danke schön!',
    'image_uploaded': 'Bild wurde hochgeladen.',
    'ok': 'OK',
    'error': 'Fehler',
    'failed_to_upload_image': 'Hochladen fehlgeschlagen. Bitte versuchen Sie es erneut.',
    'upload_image': 'Bild hochladen',
    'delete': 'Löschen',
    'delete_all_menus': 'Alle Menüs löschen',
    'delete_all_menus_confirmation': 'Möchten Sie alle Menüs wirklich löschen?',
    'Sorry.': 'Entschuldigung.',
    'Faildish': 'Gericht nicht gefunden. Bitte versuchen Sie es erneut.',
    'Preview': 'Vorschau',
    'dontdelete': 'Nicht löschen',
    'delete_all_menus_forlang': 'Möchten Sie alle bestehenden Menüs löschen?',
    'generating': 'AI-Bild wird generiert...',
  };

  // Portuguese (Português)
  final Map<String, String> _portugueseStrings = {
    'menu': 'Menu de',
    '_menu': 'Tela do menu',
    'MenuBite': 'MenuBite',
    'Lang': 'Idioma',
    'camera': 'Câmera',
    'order_history': 'Histórico de pedidos',
    'Order_Phrase': 'Tela de pedido',
    'language': 'Idioma',
    'select_language': 'Selecionar idioma',
    'cancel': 'Cancelar',
    'confirm': 'Confirmar',
    'loading': 'Carregando...',
    'menu items': 'Itens do menu',
    'show_to_staff': 'Mostre esta tela ao funcionário.',
    'I_would_like_to_order_the_dishes.': '(Eu gostaria de pedir estes pratos.)',
    'order_completed': 'Pedido concluído',
    'no_order_history': 'Nenhum histórico de pedidos.',
    'order': 'Pedido',
    'no_menu': 'Nenhum menu disponível.',
    'thank_you': 'Obrigado!',
    'image_uploaded': 'Imagem enviada.',
    'ok': 'OK',
    'error': 'Erro',
    'failed_to_upload_image': 'Falha ao enviar. Tente novamente.',
    'upload_image': 'Enviar imagem',
    'delete': 'Excluir',
    'delete_all_menus': 'Excluir todos os menus',
    'delete_all_menus_confirmation': 'Deseja excluir todos os menus?',
    'Sorry.': 'Desculpe.',
    'Faildish': 'Prato não encontrado. Tente novamente.',
    'Preview': 'Pré-visualização',
    'dontdelete': 'Não excluir',
    'delete_all_menus_forlang': 'Deseja excluir todos os menus existentes?',
    'generating': 'Gerando imagem AI...',
  };

  final Map<String, String> _russianStrings = {
    'menu': 'Меню от',
    '_menu': 'Экран меню',
    'MenuBite': 'MenuBite',
    'Lang': 'Язык',
    'camera': 'Камера',
    'order_history': 'История заказов',
    'Order_Phrase': 'Экран заказа',
    'language': 'Язык',
    'select_language': 'Выберите язык',
    'cancel': 'Отмена',
    'confirm': 'Подтвердить',
    'loading': 'Загрузка...',
    'menu items': 'Пункты меню',
    'show_to_staff': 'Пожалуйста, покажите этот экран персоналу.',
    'I_would_like_to_order_the_dishes.': '(Я хотел бы заказать эти блюда.)',
    'order_completed': 'Заказ выполнен',
    'no_order_history': 'История заказов отсутствует.',
    'order': 'Заказ',
    'no_menu': 'Меню отсутствует.',
    'thank_you': 'Спасибо!',
    'image_uploaded': 'Изображение загружено.',
    'ok': 'ОК',
    'error': 'Ошибка',
    'failed_to_upload_image': 'Ошибка загрузки. Попробуйте снова.',
    'upload_image': 'Загрузить изображение',
    'delete': 'Удалить',
    'delete_all_menus': 'Удалить все меню',
    'delete_all_menus_confirmation': 'Вы действительно хотите удалить все меню?',
    'Sorry.': 'Извините.',
    'Faildish': 'Блюдо не найдено. Попробуйте снова.',
    'Preview': 'Предпросмотр',
    'dontdelete': 'Не удалять',
    'delete_all_menus_forlang': 'Удалить все существующие меню?',
    'generating': 'Генерация AI-изображения...',
  };

  final Map<String, String> _arabicStrings = {
    'menu': 'قائمة الطعام لـ',
    '_menu': 'شاشة القائمة',
    'MenuBite': 'MenuBite',
    'Lang': 'اللغة',
    'camera': 'الكاميرا',
    'order_history': 'تاريخ الطلبات',
    'Order_Phrase': 'شاشة الطلب',
    'language': 'اللغة',
    'select_language': 'اختر اللغة',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'loading': 'جارٍ التحميل...',
    'menu items': 'عناصر القائمة',
    'show_to_staff': 'يرجى عرض هذه الشاشة على الموظف.',
    'I_would_like_to_order_the_dishes.': '(أود طلب هذه الأطباق.)',
    'order_completed': 'تم إكمال الطلب',
    'no_order_history': 'لا يوجد سجل طلبات.',
    'order': 'طلب',
    'no_menu': 'لا توجد قائمة طعام.',
    'thank_you': 'شكراً لك!',
    'image_uploaded': 'تم رفع الصورة.',
    'ok': 'موافق',
    'error': 'خطأ',
    'failed_to_upload_image': 'فشل في الرفع. حاول مرة أخرى.',
    'upload_image': 'رفع الصورة',
    'delete': 'حذف',
    'delete_all_menus': 'حذف جميع القوائم',
    'delete_all_menus_confirmation': 'هل تريد بالتأكيد حذف جميع القوائم؟',
    'Sorry.': 'عذراً.',
    'Faildish': 'لم يتم العثور على الطبق. حاول مرة أخرى.',
    'Preview': 'معاينة',
    'dontdelete': 'لا تحذف',
    'delete_all_menus_forlang': 'هل تريد حذف جميع القوائم الموجودة؟',
    'generating': 'يتم إنشاء صورة AI...',
  };

  final Map<String, String> _hindiStrings = {
    'menu': 'का मेनू',
    '_menu': 'मेनू स्क्रीन',
    'MenuBite': 'MenuBite',
    'Lang': 'भाषा',
    'camera': 'कैमरा',
    'order_history': 'आदेश इतिहास',
    'Order_Phrase': 'आदेश स्क्रीन',
    'language': 'भाषा',
    'select_language': 'भाषा चुनें',
    'cancel': 'रद्द करें',
    'confirm': 'पुष्टि करें',
    'loading': 'लोड हो रहा है...',
    'menu items': 'मेनू आइटम',
    'show_to_staff': 'कृपया यह स्क्रीन स्टाफ को दिखाएं।',
    'I_would_like_to_order_the_dishes.': '(मैं इन व्यंजनों का आदेश देना चाहूंगा।)',
    'order_completed': 'आदेश पूरा हुआ',
    'no_order_history': 'कोई आदेश इतिहास नहीं है।',
    'order': 'आदेश',
    'no_menu': 'कोई मेनू उपलब्ध नहीं है।',
    'thank_you': 'धन्यवाद!',
    'image_uploaded': 'छवि अपलोड हो गई है।',
    'ok': 'ठीक है',
    'error': 'त्रुटि',
    'failed_to_upload_image': 'अपलोड करने में विफल। कृपया पुनः प्रयास करें।',
    'upload_image': 'छवि अपलोड करें',
    'delete': 'हटाएं',
    'delete_all_menus': 'सभी मेनू हटाएं',
    'delete_all_menus_confirmation': 'क्या आप सभी मेनू को हटाना चाहते हैं?',
    'Sorry.': 'माफ़ कीजिए।',
    'Faildish': 'डिश नहीं मिली। कृपया पुनः प्रयास करें।',
    'Preview': 'पूर्वावलोकन',
    'dontdelete': 'हटाएं नहीं',
    'delete_all_menus_forlang': 'क्या आप सभी मौजूदा मेनू हटाना चाहते हैं?',
    'generating': 'AI छवि उत्पन्न की जा रही है...',
  };

  final Map<String, String> _italianStrings = {
    'menu': 'Menu di',
    '_menu': 'Schermata menu',
    'MenuBite': 'MenuBite',
    'Lang': 'Lingua',
    'camera': 'Fotocamera',
    'order_history': 'Cronologia ordini',
    'Order_Phrase': 'Schermata ordine',
    'language': 'Lingua',
    'select_language': 'Seleziona lingua',
    'cancel': 'Annulla',
    'confirm': 'Conferma',
    'loading': 'Caricamento...',
    'menu items': 'Elementi del menu',
    'show_to_staff': 'Si prega di mostrare questa schermata al personale.',
    'I_would_like_to_order_the_dishes.': '(Vorrei ordinare questi piatti.)',
    'order_completed': 'Ordine completato',
    'no_order_history': 'Nessuna cronologia ordini.',
    'order': 'Ordine',
    'no_menu': 'Nessun menu disponibile.',
    'thank_you': 'Grazie!',
    'image_uploaded': 'Immagine caricata.',
    'ok': 'OK',
    'error': 'Errore',
    'failed_to_upload_image': 'Caricamento fallito. Riprova.',
    'upload_image': 'Carica immagine',
    'delete': 'Elimina',
    'delete_all_menus': 'Elimina tutti i menu',
    'delete_all_menus_confirmation': 'Sei sicuro di voler eliminare tutti i menu?',
    'Sorry.': 'Mi dispiace.',
    'Faildish': 'Piatto non trovato. Riprova.',
    'Preview': 'Anteprima',
    'dontdelete': 'Non eliminare',
    'delete_all_menus_forlang': 'Vuoi eliminare tutti i menu esistenti?',
    'generating': 'Generazione immagine AI in corso...',
  };
}
