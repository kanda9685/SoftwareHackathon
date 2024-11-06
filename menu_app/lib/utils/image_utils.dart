import 'dart:io';
import 'package:image/image.dart' as img;

Future<File> rotateAndSaveImage(File imageFile) async {
  final originalImage = img.decodeImage(await imageFile.readAsBytes());
  final rotatedImage = img.copyRotate(originalImage!, angle: 0);
  final newPath = imageFile.path.replaceAll('.jpg', '_rotated.jpg');
  final File newImageFile = File(newPath);
  await newImageFile.writeAsBytes(img.encodeJpg(rotatedImage));

  return newImageFile;
}
