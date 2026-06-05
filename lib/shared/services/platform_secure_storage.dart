import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Cross-platform secure storage with Hive fallback on web.
class PlatformSecureStorage {
  static const _hiveBoxName = 'settings';
  static const _hivePrefix = 'secure_';

  static FlutterSecureStorage? _mobileStorage;

  static FlutterSecureStorage get _storage {
    _mobileStorage ??= const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked,
      ),
      webOptions: WebOptions(
        dbName: 'rozgar_secure',
        publicKey: 'rozgar_web_storage',
      ),
    );
    return _mobileStorage!;
  }

  static Future<String?> read(String key) async {
    if (kIsWeb) {
      return Hive.box(_hiveBoxName).get('$_hivePrefix$key') as String?;
    }
    return _storage.read(key: key);
  }

  static Future<void> write(String key, String value) async {
    if (kIsWeb) {
      await Hive.box(_hiveBoxName).put('$_hivePrefix$key', value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  static Future<void> delete(String key) async {
    if (kIsWeb) {
      await Hive.box(_hiveBoxName).delete('$_hivePrefix$key');
      return;
    }
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    if (kIsWeb) {
      final box = Hive.box(_hiveBoxName);
      final keys = box.keys
          .where((k) => k.toString().startsWith(_hivePrefix))
          .toList();
      for (final key in keys) {
        await box.delete(key);
      }
      return;
    }
    await _storage.deleteAll();
  }
}
