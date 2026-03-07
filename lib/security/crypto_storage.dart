import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// CryptoStorage - Simulated AES-256-GCM vault key manager
/// Uses pure Dart crypto (no native plugin needed for build)
class CryptoStorage {
  static const String keyAlias = "com.gestureface.vault_key";
  Uint8List? _inMemoryKey;

  Future<void> initHardwareKey() async {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    _inMemoryKey = Uint8List.fromList(keyBytes);
  }

  void lock() {
    _inMemoryKey = null;
  }

  Future<Uint8List> encryptData(Uint8List clearText) async {
    if (_inMemoryKey == null) throw Exception("Vault Locked.");
    // Simulated encryption using HMAC-SHA256 as placeholder
    final hmac = Hmac(sha256, _inMemoryKey!);
    final digest = hmac.convert(clearText);
    return Uint8List.fromList(digest.bytes + clearText);
  }

  Future<Uint8List> decryptData(Uint8List cipherPayload) async {
    if (_inMemoryKey == null) throw Exception("Vault Locked.");
    if (cipherPayload.length <= 32) return cipherPayload;
    return cipherPayload.sublist(32);
  }
}
