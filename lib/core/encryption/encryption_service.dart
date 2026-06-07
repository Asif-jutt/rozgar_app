import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rozgar/core/logger/app_logger.dart';

/// AES encryption for sensitive fields (CV URLs, resume text, CNIC).
class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

  static const _keyStorageKey = 'rozgar_aes_key';
  static const _ivStorageKey = 'rozgar_aes_iv';
  static const _encryptedPrefix = 'enc:';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Encrypter? _encrypter;
  IV? _iv;

  Future<void> initialize() async {
    try {
      var keyStr = await _storage.read(key: _keyStorageKey);
      var ivStr = await _storage.read(key: _ivStorageKey);

      if (keyStr == null || ivStr == null) {
        final key = Key.fromSecureRandom(32);
        final iv = IV.fromSecureRandom(16);
        keyStr = base64Encode(key.bytes);
        ivStr = base64Encode(iv.bytes);
        await _storage.write(key: _keyStorageKey, value: keyStr);
        await _storage.write(key: _ivStorageKey, value: ivStr);
      }

      _encrypter = Encrypter(AES(Key(base64Decode(keyStr))));
      _iv = IV(base64Decode(ivStr));
      AppLogger.info('EncryptionService initialized');
    } catch (e, st) {
      AppLogger.error('EncryptionService init failed', e, st);
    }
  }

  bool get isReady => _encrypter != null && _iv != null;

  String encrypt(String plainText) {
    if (plainText.isEmpty) return plainText;
    if (!isReady) return plainText;
    if (plainText.startsWith(_encryptedPrefix)) return plainText;
    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
      return '$_encryptedPrefix${encrypted.base64}';
    } catch (e) {
      AppLogger.warning('Encrypt failed', e);
      return plainText;
    }
  }

  String decrypt(String cipherText) {
    if (cipherText.isEmpty) return cipherText;
    if (!cipherText.startsWith(_encryptedPrefix)) return cipherText;
    if (!isReady) return cipherText;
    try {
      final payload = cipherText.substring(_encryptedPrefix.length);
      return _encrypter!.decrypt(Encrypted.fromBase64(payload), iv: _iv!);
    } catch (e) {
      AppLogger.warning('Decrypt failed', e);
      return cipherText;
    }
  }
}
