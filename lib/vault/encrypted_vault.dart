import 'dart:typed_data';
import '../security/crypto_storage.dart';
import '../core/event_bus.dart';

class EncryptedVault {
  final CryptoStorage cryptoStorage;
  final EventBus eventBus;

  EncryptedVault({required this.cryptoStorage, required this.eventBus});

  /// Sauvegarde sécurisée de métadonnées utilisateur.
  Future<void> storeSensitiveNote(String id, String content) async {
    try {
      final bytesContent = Uint8List.fromList(content.codeUnits);
      final encryptedBytes = await cryptoStorage.encryptData(bytesContent);
      
      // Simule un stockage SQLCipher
      await _simulateSqliteInsert(id, encryptedBytes);
    } catch (e) {
      if (e.toString().contains("Locked")) {
        eventBus.fire(AppEvent.tamperDetected, {'threat': 'illegal_vault_write_attempt'});
      }
      rethrow;
    }
  }

  Future<String> readSensitiveNote(String id) async {
      // Simule un read SQLCipher
      final encryptedBytes = await _simulateSqliteSelect(id);
      final clearBytes = await cryptoStorage.decryptData(encryptedBytes);
      return String.fromCharCodes(clearBytes);
  }

  Future<void> _simulateSqliteInsert(String id, Uint8List payload) async {}
  Future<Uint8List> _simulateSqliteSelect(String id) async { return Uint8List(0); }

  void lockVault() {
    cryptoStorage.lock();
    eventBus.fire(AppEvent.vaultLocked);
  }

  Future<void> unlockVault() async {
    await cryptoStorage.initHardwareKey();
    eventBus.fire(AppEvent.vaultUnlocked);
  }
}
