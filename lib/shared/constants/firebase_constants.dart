import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:rozgar/shared/services/platform_secure_storage.dart';

class FirebaseCollections {
  static const users = 'users';
  static const jobs = 'jobs';
  static const applications = 'applications';
  static const savedJobs = 'savedJobs';
  static const notifications = 'notifications';
  static const reports = 'reports';
  static const config = 'config';
  static const companies = 'companies';
  static const notificationsQueue = 'notifications_queue';
}

class EncryptionHelper {
  static const _keyStorageKey = 'aes_key';
  static enc.Key? _key;
  static enc.Encrypter? _encrypter;

  static Future<void> generateAndStoreKey() async {
    String? keyStr = await PlatformSecureStorage.read(_keyStorageKey);
    if (keyStr == null) {
      final key = enc.Key.fromSecureRandom(32);
      keyStr = key.base64;
      await PlatformSecureStorage.write(_keyStorageKey, keyStr);
    }
    _key = enc.Key.fromBase64(keyStr);
    _encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
  }

  static String encryptString(String plain) {
    if (plain.isEmpty || _encrypter == null) return plain;
    try {
      final iv = enc.IV.fromSecureRandom(16);
      final encrypted = _encrypter!.encrypt(plain, iv: iv);
      return 'ENC:${iv.base64}:${encrypted.base64}';
    } catch (_) {
      return plain;
    }
  }

  static String decryptString(String value) {
    if (!_isEncrypted(value) || _encrypter == null) return value;
    try {
      final payload = value.substring(4);
      final parts = payload.split(':');
      if (parts.length != 2) return value;
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);
      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (_) {
      return value;
    }
  }

  static bool _isEncrypted(String value) => value.startsWith('ENC:');
}

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();
  static String currentRole = 'USER';

  late final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
    level: kDebugMode ? Level.debug : Level.warning,
  );

  static String _prefix() {
    switch (currentRole) {
      case 'employer':
        return '[COMPANY]';
      case 'admin':
        return '[ADMIN]';
      default:
        return '[USER]';
    }
  }

  static void i(String message) {
    final msg = '${_prefix()} $message';
    if (kDebugMode) {
      instance._logger.i(msg);
    }
  }

  static void d(String message) {
    final msg = '${_prefix()} $message';
    if (kDebugMode) {
      instance._logger.d(msg);
    }
  }

  static void w(String message) {
    final msg = '${_prefix()} $message';
    if (kDebugMode) {
      instance._logger.w(msg);
    } else if (!kIsWeb) {
      FirebaseCrashlytics.instance.log(msg);
    }
  }

  static void e(dynamic error, [StackTrace? st]) {
    final msg = '${_prefix()} $error';
    if (kDebugMode) {
      instance._logger.e(msg, error: error, stackTrace: st);
    } else if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, st, reason: msg);
    }
  }
}

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  factory DioClient.jSearch() {
    final d = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _attachInterceptors(d, 'jsearch');
    return DioClient._(d);
  }

  factory DioClient.countries() {
    final d = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _attachInterceptors(d, 'countries');
    return DioClient._(d);
  }

  factory DioClient.exchange() {
    final d = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _attachInterceptors(d, 'exchange');
    d.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.request,
          maxStale: const Duration(hours: 1),
        ),
      ),
    );
    return DioClient._(d);
  }

  factory DioClient.base() {
    final d = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    _attachInterceptors(d, 'base');
    return DioClient._(d);
  }

  static void _attachInterceptors(Dio d, String tag) {
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['start'] = DateTime.now();
          handler.next(options);
        },
        onResponse: (response, handler) {
          final start = response.requestOptions.extra['start'] as DateTime?;
          final ms = start != null
              ? DateTime.now().difference(start).inMilliseconds
              : 0;
          AppLogger.i(
            'API [$tag] ${response.requestOptions.method} '
            '${response.requestOptions.uri} → ${response.statusCode} (${ms}ms)',
          );
          FirestoreReadCounter.lastApiUrl = response.requestOptions.uri
              .toString();
          FirestoreReadCounter.lastApiDurationMs = ms;
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout) {
            try {
              final response = await d.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (_) {}
          }
          final code = error.response?.statusCode;
          String msg;
          switch (code) {
            case 401:
              msg = 'Unauthorized — check API key';
            case 403:
              msg = 'Forbidden — access denied';
            case 404:
              msg = 'Resource not found';
            case 500:
              msg = 'Server error — try again later';
            default:
              msg = error.message ?? 'Network error';
          }
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: msg,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }
}

class FirestoreReadCounter {
  static int readCount = 0;
  static String lastApiUrl = '';
  static int lastApiDurationMs = 0;

  static void increment([int n = 1]) => readCount += n;
}
