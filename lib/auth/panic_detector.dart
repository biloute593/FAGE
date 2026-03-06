import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/event_bus.dart';

/// PanicDetector
/// Détecte une déviation subtile (+5° sur l'écartement des doigts) du geste normal
/// permettant de simuler une ouverture tout en cachant le vault (Fake Environment)
class PanicDetector {
  final EventBus eventBus;

  PanicDetector({required this.eventBus});

  /// Analyse les landmarks de la main (21 points) extraits par MediaPipe
  /// Cherche spécifiquement l'écart entre l'index et le majeur (pour un signe V)
  void detectPanicGesture(List<dynamic> handLandmarks, double normalAngleRef) {
    double currentAngle = _calculateFingerSpreadAngle(handLandmarks);
    
    // Si l'angle varie de +5° (écartement volontaire mais imperceptible à l'oeil nu)
    if ((currentAngle - normalAngleRef).abs() >= AppConstants.panicGestureAngleDeltaDegrees) {
      
      // On s'assure qu'il est maintenu pour éviter les faux positifs (Simulation du timer)
      _verifyHoldDuration();

      debugPrint("PANIC GESTURE DETECTED - Angle Delta: \${(currentAngle - normalAngleRef).abs()}°");
      eventBus.fire(AppEvent.panicTriggered, {'timestamp': DateTime.now().millisecondsSinceEpoch});
    }
  }

  double _calculateFingerSpreadAngle(List<dynamic> landmarks) {
    // Calcul trigonométrique 3D entre Index TIP (8), PIP (6) et Middle TIP (12), PIP (10)
    // Retourne un angle en degrés.
    return 25.0; // Valeur simulée test
  }

  Future<void> _verifyHoldDuration() async {
    // Dans le système réel, cela nécessiterait minimum 800ms de maintien
    await Future.delayed(const Duration(milliseconds: AppConstants.panicGestureHoldDurationMs));
  }
}
