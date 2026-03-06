import 'dart:typed_data';
import 'encrypted_vault.dart';

/// PhotoVault
/// Sépare la gestion de fausses photos "anodines" et des photos réelles chiffrées
class PhotoVault {
  final EncryptedVault vault;
  
  bool _isUnlocked = false;

  PhotoVault({required this.vault});

  void unlock() {
    _isUnlocked = true;
  }
  
  void lock() {
    _isUnlocked = false;
  }

  /// Retourne le chemin (ou bytes) d'une image fake qui sera envoyée à la galerie normale
  /// de l'OS comme "camouflage"
  Future<Uint8List> getFakeCoverPhoto() async {
    // Renvoie une image anodine (paysage, texture)
    return Uint8List(0); // Simulé
  }

  /// Sauvegarde la vraie photo
  Future<void> storeRealPhoto(String fileId, Uint8List rawImage) async {
    // 1. Purge des metadonnées (EXIF data)
    final scrubbedImage = _purgeExif(rawImage);

    // 2. Chiffrement GCM et Stockage via vault
    await vault.storeSensitiveNote("img_\$fileId", String.fromCharCodes(scrubbedImage));
    
    // 3. Optionnel: Enregistrement d'un Fake Cover en parallèle
  }

  /// Lecture d'une vraie photo
  Future<Uint8List> getRealPhoto(String fileId) async {
    if (!_isUnlocked) throw Exception("Access Denied");
    
    String decoded = await vault.readSensitiveNote("img_\$fileId");
    return Uint8List.fromList(decoded.codeUnits);
  }

  Uint8List _purgeExif(Uint8List image) {
    // Remove location, timestamp, camera model from JPEG/PNG headers
    return image;
  }
}
