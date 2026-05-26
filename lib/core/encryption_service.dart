import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EncryptionService {
  static final _storage = const FlutterSecureStorage();
  static const _keyAlias = 'encryption_key';
  static Key? _key;
  static final _iv = IV.fromLength(16);
  static Encrypter? _encrypter;
  
  // Shared deterministic key for MVP across multiple users
  static const String _sharedSecret = 'rozgar_app_secure_key_1234567890'; // 32 bytes

  static Future<void> init() async {
    // For a real production app with E2E, this key would be exchanged securely. 
    // Here we use a symmetric 32-byte key shared across the app environment so both sender and receiver can decrypt.
    _key = Key.fromUtf8(_sharedSecret);
    _encrypter = Encrypter(AES(_key!));
  }

  static String encryptMessage(String plainText) {
    if (_encrypter == null) return plainText;
    try {
      return _encrypter!.encrypt(plainText, iv: _iv).base64;
    } catch (e) {
      return plainText; 
    }
  }

  static String decryptMessage(String encryptedText) {
    if (_encrypter == null) return encryptedText;
    try {
      return _encrypter!.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return encryptedText;
    }
  }
}
