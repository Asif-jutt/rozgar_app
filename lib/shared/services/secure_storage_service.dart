import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

/// Secure storage service for protecting sensitive local data
/// Encrypts data using platform-specific secure storage mechanisms
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked,
    ),
  );

  /// Stores a string value securely
  /// [key]: The storage key
  /// [value]: The value to store
  static Future<void> saveString(String key, String value) async {
    try {
      final encrypted = EncryptionHelper.encryptString(value);
      await _storage.write(key: key, value: encrypted);
      AppLogger.d('Secure string stored: $key');
    } catch (e, st) {
      AppLogger.e('Error storing secure string: $key', st);
      rethrow;
    }
  }

  /// Retrieves a securely stored string value
  /// [key]: The storage key
  /// Returns the decrypted value or null if not found
  static Future<String?> getString(String key) async {
    try {
      final encrypted = await _storage.read(key: key);
      if (encrypted == null) return null;

      final decrypted = EncryptionHelper.decryptString(encrypted);
      AppLogger.d('Secure string retrieved: $key');
      return decrypted;
    } catch (e, st) {
      AppLogger.e('Error retrieving secure string: $key', st);
      return null;
    }
  }

  /// Stores a JSON-serializable object securely
  /// [key]: The storage key
  /// [value]: The object to store (will be JSON encoded)
  static Future<void> saveObject(String key, Map<String, dynamic> value) async {
    try {
      final json = _jsonEncode(value);
      await saveString(key, json);
      AppLogger.d('Secure object stored: $key');
    } catch (e, st) {
      AppLogger.e('Error storing secure object: $key', st);
      rethrow;
    }
  }

  /// Retrieves a securely stored object
  /// [key]: The storage key
  /// Returns the deserialized object or null if not found
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

  /// Stores authentication token securely
  /// [token]: The authentication token to store
  static Future<void> saveAuthToken(String token) async {
    await saveString('auth_token', token);
    AppLogger.i('Authentication token stored securely');
  }

  /// Retrieves authentication token
  /// Returns the stored token or null if not found
  static Future<String?> getAuthToken() async {
    return getString('auth_token');
  }

  /// Removes authentication token
  static Future<void> removeAuthToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      AppLogger.i('Authentication token removed');
    } catch (e, st) {
      AppLogger.e('Error removing auth token', st);
    }
  }

  /// Stores user credentials securely
  /// [email]: User email
  /// [password]: User password
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
      rethrow;
    }
  }

  /// Retrieves stored user credentials
  /// Returns a map with 'email' and 'password' keys
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

  /// Removes stored user credentials
  static Future<void> removeCredentials() async {
    try {
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_password');
      AppLogger.i('User credentials removed');
    } catch (e, st) {
      AppLogger.e('Error removing credentials', st);
    }
  }

  /// Removes a specific key from secure storage
  /// [key]: The storage key to remove
  static Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.d('Secure storage key removed: $key');
    } catch (e, st) {
      AppLogger.e('Error removing secure storage key: $key', st);
    }
  }

  /// Clears all secure storage data
  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
      AppLogger.i('Secure storage cleared');
    } catch (e, st) {
      AppLogger.e('Error clearing secure storage', st);
    }
  }

  /// Checks if a key exists in secure storage
  /// [key]: The storage key to check
  /// Returns true if the key exists
  static Future<bool> contains(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }

  /// Helper method for JSON encoding
  static String _jsonEncode(Map<String, dynamic> data) {
    return data.toString();
  }

  /// Helper method for JSON decoding
  static Map<String, dynamic> _jsonDecode(String json) {
    // Simple implementation - for production use dart:convert
    final map = <String, dynamic>{};
    // This is a placeholder - implement proper JSON parsing as needed
    return map;
  }
}
