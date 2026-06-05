import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  Stream<double> uploadResume(File file) async* {
    final ext = file.path.split('.').last.toLowerCase();
    if (ext != 'pdf') throw ValidationException('Only PDF files are allowed');
    if (file.lengthSync() > 5 * 1024 * 1024) {
      throw ValidationException('PDF must be under 5MB');
    }

    final controller = StreamController<double>();
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': uploadPreset,
        'folder': 'rozgar/resumes',
      });
      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
        data: formData,
        onSendProgress: (sent, total) {
          final p = sent / total;
          controller.add(p);
        },
      );
      controller.add(1.0);
      final data = response.data as Map<String, dynamic>;
      yield 1.0;
      AppLogger.i('Resume uploaded: ${data['public_id']}');
    } catch (e) {
      AppLogger.e(e);
      rethrow;
    } finally {
      await controller.close();
    }
  }

  Future<Map<String, String>> uploadResumeSync(
    File file, {
    void Function(double)? onProgress,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (ext != 'pdf') throw ValidationException('Only PDF files are allowed');
    if (file.lengthSync() > 5 * 1024 * 1024) {
      throw ValidationException('PDF must be under 5MB');
    }
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
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

  Future<Map<String, String>> uploadImage(
    File file, {
    required String folder,
    void Function(double)? onProgress,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      throw ValidationException('Only JPG, PNG, or WebP allowed');
    }
    if (file.lengthSync() > 3 * 1024 * 1024) {
      throw ValidationException('Image must be under 3MB');
    }

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      quality: 85,
      minWidth: 1024,
    );
    final uploadFile = compressed != null ? File(compressed.path) : file;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(uploadFile.path),
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
