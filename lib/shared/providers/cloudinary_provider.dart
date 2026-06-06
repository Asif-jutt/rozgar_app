import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}

class CloudinaryService {
  static final CloudinaryService instance = CloudinaryService._();
  CloudinaryService._();

  String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'demo';
  String get uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'rozgar_unsigned';
  final Dio _dio = DioClient.base().dio;

  Future<Map<String, String>> uploadResumeBytes(
    Uint8List bytes, {
    required String filename,
    void Function(double)? onProgress,
  }) async {
    final ext = filename.split('.').last.toLowerCase();
    if (ext != 'pdf') throw ValidationException('Only PDF files are allowed');
    if (bytes.length > 5 * 1024 * 1024) {
      throw ValidationException('PDF must be under 5MB');
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'upload_preset': uploadPreset,
      'folder': 'rozgar/resumes',
    });
    final response = await _dio.post(
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
      data: formData,
      onSendProgress: (sent, total) => onProgress?.call(sent / total),
    );
    final data = response.data as Map<String, dynamic>;
    return {
      'secureUrl': data['secure_url'] as String,
      'publicId': data['public_id'] as String,
    };
  }

  Future<Map<String, String>> uploadImageBytes(
    Uint8List bytes, {
    required String filename,
    required String folder,
    void Function(double)? onProgress,
  }) async {
    final ext = filename.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      throw ValidationException('Only JPG, PNG, or WebP allowed');
    }
    if (bytes.length > 3 * 1024 * 1024) {
      throw ValidationException('Image must be under 3MB');
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'upload_preset': uploadPreset,
      'folder': folder,
      'transformation': 'c_fill,g_face,w_400,h_400',
    });
    final response = await _dio.post(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      data: formData,
      onSendProgress: (sent, total) => onProgress?.call(sent / total),
    );
    final data = response.data as Map<String, dynamic>;
    return {
      'secureUrl': data['secure_url'] as String,
      'publicId': data['public_id'] as String,
    };
  }

  Future<void> deleteFile(String publicId) async {
    try {
      await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
        data: {'public_id': publicId, 'upload_preset': uploadPreset},
      );
      AppLogger.i('Deleted Cloudinary file: $publicId');
    } catch (e) {
      AppLogger.w('Failed to delete Cloudinary file: $e');
    }
  }
}
