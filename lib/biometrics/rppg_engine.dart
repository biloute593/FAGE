import 'dart:async';
import 'package:camera/camera.dart';
import '../core/event_bus.dart';
import '../core/constants.dart';
import '../core/feature_flags.dart';

/// rPPG Engine (Remote Photoplethysmography)
/// Module Deep Learning d'extraction du signal cardiaque depuis la vidéo (skin-inclusive).
/// MVP Rule : Conditionnel et optionnellement bloquant.
class RppgEngine {
  final EventBus eventBus;

  RppgEngine({required this.eventBus});

  /// Extrait le pouls et la confiance du signal à partir des frames accumulées.
  Future<void> evaluateRppgSignal(List<CameraImage> croppedFaceFrames) async {
    if (!FeatureFlags.enableRppgMlModel) {
      // Ignorer si flag désactivé
      return;
    }

    try {
      // Simulation appel ML Model (Entraîné Fitzpatrick I-VI) : ~20ms
      await Future.delayed(const Duration(milliseconds: 20));
      
      double confidence = _extractRppgConfidence(croppedFaceFrames);
      
      if (confidence > AppConstants.rppgConfidenceThreshold) {
        eventBus.fire(AppEvent.rppgSignalReady, {'confidence': confidence, 'status': 'valid'});
      } else {
        // En MVP, un rPPG faible (< 0.70) n'est pas utilisé ou ignoré pour éviter
        // un refus injustifié (en attendant des retours réels).
        eventBus.fire(AppEvent.rppgSignalReady, {'confidence': confidence, 'status': 'low_confidence_ignored'});
      }
    } catch (e) {
      eventBus.fire(AppEvent.rppgSignalReady, {'status': 'error_ignored'});
    }
  }

  double _extractRppgConfidence(List<CameraImage> frames) {
    // Calcul de l'estimation du rythme cardiaque via fluctuations micro-vasculaires
    // Retourne un score de confiance de la mesure. MAE < 3 bpm ciblé en prod.
    return 0.85; // Simulated high confidence
  }
}
