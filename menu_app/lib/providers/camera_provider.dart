import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// CameraProviderクラスの定義
class CameraProvider with ChangeNotifier {
  final CameraDescription _camera;

  CameraProvider(this._camera);

  CameraDescription get camera => _camera;

  // カメラを変更したときに状態を通知するメソッド
  void updateCamera(CameraDescription newCamera) {
    notifyListeners(); // 状態変更を通知
  }
}