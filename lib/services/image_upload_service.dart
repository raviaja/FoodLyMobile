import 'dart:io';
import 'package:dio/dio.dart';

class ImageUploadService {
  static const String _cloudName = 'ddaapditw';
  static const String _uploadPreset = 'foodly_images';

  static final Dio _dio = Dio();

  /// Upload foto ke Cloudinary, return URL string
  static Future<String> uploadImage(File imageFile) async {
    final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      'upload_preset': _uploadPreset,
    });

    final response = await _dio.post(url, data: formData);

    if (response.statusCode == 200) {
      return response.data['secure_url'] as String;
    }

    throw Exception('Gagal mengupload gambar ke Cloudinary');
  }
}