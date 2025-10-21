import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

 
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

 
  Future<bool> hasCameraPermission() async {
    var status = await Permission.camera.status;
    return status.isGranted;
  }

  // Tomar foto con la cámara
  Future<File?> takePhoto({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      bool hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        throw Exception('Permiso de cámara denegado');
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Seleccionar foto de la galería
  Future<File?> pickImageFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Convertir imagen a Base64
  Future<String> convertImageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener tamaño del archivo en MB
  Future<double> getImageSizeInMB(File imageFile) async {
    int sizeInBytes = await imageFile.length();
    return sizeInBytes / (1024 * 1024);
  }
}