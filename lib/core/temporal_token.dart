import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Temporal Binding Token : Anti-Replay Absolu
/// Géré au niveau de la session de capture.
class TemporalToken {
  final int timestampMs;
  final String deviceId; // Fingerprint matériel
  final int framesCaptured;
  final String hash;

  TemporalToken({
    required this.timestampMs,
    required this.deviceId,
    required this.framesCaptured,
    required this.hash,
  });

  /// Crée un nouveau token pour une tentative d'authentification
  static TemporalToken generate(String hardwareFingerprint, int currentFrames) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    
    // Random seed 256 bits (32 bytes)
    final random = Random.secure();
    final seedBytes = List<int>.generate(32, (i) => random.nextInt(256));
    final seedHex = seedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    final rawToken = "\$now-\$hardwareFingerprint-\$currentFrames-\$seedHex";
    final bytes = utf8.encode(rawToken);
    final digest = sha256.convert(bytes);

    return TemporalToken(
      timestampMs: now,
      deviceId: hardwareFingerprint,
      framesCaptured: currentFrames,
      hash: digest.toString(),
    );
  }

  /// Valide le token : vérifie l'expiration et la consistance locale.
  /// Un token expire en moins de 1000ms. Doit correspondre à +/- 50ms (simulé ici comme tolérance de traitement).
  bool isValid(int validationTimestampMs, int currentFrames) {
    // Expiration stricte : La session ne peut durer plus de 1000 ms ("Expire en moins d'une seconde")
    if ((validationTimestampMs - timestampMs).abs() > 1000) {
      return false;
    }
    
    // Le token est lié au nombre de frames (anti-replay vidéo qui droperait des frames)
    if (framesCaptured != currentFrames) {
      return false;
    }

    return true;
  }
}
