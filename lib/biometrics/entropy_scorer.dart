import 'dart:math';
import '../core/constants.dart';
import '../core/event_bus.dart';

/// Gesture Entropy Score
/// Analyse la variation d'un geste. Un geste répliqué trop parfaitement est une attaque Replay/Deepfake.
class EntropyScorer {
  final EventBus eventBus;

  EntropyScorer({required this.eventBus});

  /// Calcule l'entropie d'un geste par rapport au template enregistré (lors de l'inscription).
  /// Retourne un score de similarité/variation statique.
  Future<bool> validateEntropy(String currentSignature, String enrolledSignature) async {
    // Calcul simulé de la distance de Levenshtein ou Dynamic Time Warping (DTW)
    double entropy = _calculateSignalEntropy(currentSignature, enrolledSignature);
    
    // Paradoxe sécuritaire : La perfection (trop faible entropie) est rejetée.
    bool isValid = (entropy > AppConstants.minEntropy) && (entropy < AppConstants.maxEntropy);

    if (isValid) {
      eventBus.fire(AppEvent.entropyValid, {'score': entropy});
    } else {
      eventBus.fire(AppEvent.entropyInvalid, {'score': entropy});
    }

    return isValid;
  }

  double _calculateSignalEntropy(String s1, String s2) {
    // Dans une implémentation réelle, ceci évaluerait les variations d'angles des jointures et vélocité.
    // Humain réel : variation naturelle = 0.15 - 0.35
    // Deepfake / script : 0.02 - 0.05
    final random = Random();
    // Simulate natural human entropy (0.15 - 0.35)
    return 0.15 + random.nextDouble() * 0.20; 
  }
}
