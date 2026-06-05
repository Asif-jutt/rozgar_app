import 'package:flutter/foundation.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/services/platform_secure_storage.dart';

/// Secure storage service for protecting sensitive local data.
class SecureStorageService {
  static Future<void> saveString(String key, String value) async {
    try {
      final encrypted = EncryptionHelper.encryptString(value);
      await PlatformSecureStorage.write(key, encrypted);
      AppLogger.d('Secure string stored: $key');
    } catch (e, st) {
      AppLogger.e('Error storing secure string: $key', st);
      if (!kIsWeb) rethrow;
    }
  }

  static Future<String?> getString(String key) async {
    try {
      final encrypted = await PlatformSecureStorage.read(key);
      if (encrypted == null) return null;

      final decrypted = EncryptionHelper.decryptString(encrypted);
      AppLogger.d('Secure string retrieved: $key');
      return decrypted;
    } catch (e, st) {
      AppLogger.e('Error retrieving secure string: $key', st);
      return null;
    }
  }

  static Future<void> saveObject(String key, Map<String, dynamic> value) async {
    try {
      final json = _jsonEncode(value);
      await saveString(key, json);
      AppLogger.d('Secure object stored: $key');
    } catch (e, st) {
      AppLogger.e('Error storing secure object: $key', st);
      if (!kIsWeb) rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final json = await getString(key);
      if (json == null) return null;

      final object = _jsonDecode(json);
      AppLogger.d('Secure object retrieved: $key');
      return object;
    } catch (e, st) {
      AppLogger.e('Error retrieving secure object: $key', st);
      return null;
    }
  }

  static Future<void> saveAuthToken(String token) async {
    await saveString('auth_token', token);
    AppLogger.i('Authentication token stored securely');
  }

  static Future<String?> getAuthToken() => getString('auth_token');

  static Future<void> removeAuthToken() async {
    try {
      await PlatformSecureStorage.delete('auth_token');
      AppLogger.i('Authentication token removed');
    } catch (e, st) {
      AppLogger.e('Error removing auth token', st);
    }
  }

  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await saveString('user_email', email);
      await saveString('user_password', password);
      AppLogger.i('User credentials stored securely');
    } catch (e, st) {
      AppLogger.e('Error storing credentials', st);
      if (!kIsWeb) rethrow;
    }
  }

  static Future<Map<String, String>?> getCredentials() async {
    try {
      final email = await getString('user_email');
      final password = await getString('user_password');

      if (email == null || password == null) return null;

      AppLogger.i('User credentials retrieved');
      return {'email': email, 'password': password};
    } catch (e, st) {
      AppLogger.e('Error retrieving credentials', st);
      return null;
    }
  }

  static Future<void> removeCredentials() async {
    try {
      await PlatformSecureStorage.delete('user_email');
      await PlatformSecureStorage.delete('user_password');
      AppLogger.i('User credentials removed');
    } catch (e, st) {
      AppLogger.e('Error removing credentials', st);
    }
  }

  static Future<void> remove(String key) async {
    try {
      await PlatformSecureStorage.delete(key);
      AppLogger.d('Secure storage key removed: $key');
    } catch (e, st) {
      AppLogger.e('Error removing secure storage key: $key', st);
    }
  }

  static Future<void> clear() async {
    try {
      await PlatformSecureStorage.deleteAll();
      AppLogger.i('Secure storage cleared');
    } catch (e, st) {
      AppLogger.e('Error clearing secure storage', st);
    }
  }

  static Future<bool> contains(String key) async {
    try {
      final value = await PlatformSecureStorage.read(key);
      return value != null;
    } catch (e) {
      return false;
    }
  }

  static String _jsonEncode(Map<String, dynamic> data) => data.toString();

  static Map<String, dynamic> _jsonDecode(String json) => <String, dynamic>{};
}
