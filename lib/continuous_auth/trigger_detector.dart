import 'dart:async';
import '../core/event_bus.dart';

/// Trigger Detector
/// Analyse les métriques comportementales pour décider du réveil de MediaPipe
class TriggerDetector {
  final EventBus eventBus;
  
  bool _isCameraAwake = false;

  TriggerDetector({required this.eventBus});

  /// Analyse le flux 50Hz de l'IMU (Accelerometer/Gyroscope)
  void analyzeMotionData({
    required double ax, required double ay, required double az,
    required double gx, required double gy, required double gz
  }) {
    if (_isCameraAwake) return; // Déjà en cours d'analyse lourde

    // Pattern de vol à l'arraché (Accélération brusque anormale)
    // Ou changement d'orientation indiquant que le téléphone a changé de main
    bool isAnomalousMotion = _detectAnomaly(ax, ay, az, gx, gy, gz);

    if (isAnomalousMotion) {
      _wakeUpHeavyBiometrics();
    }
  }

  bool _detectAnomaly(double ax, double ay, double az, double gx, double gy, double gz) {
    // Simulation: Normal behavior
    return false;
  }

  void _wakeUpHeavyBiometrics() async {
    _isCameraAwake = true;
    eventBus.fire(AppEvent.continuousAuthAlert, {'reason': 'motion_anomaly'});
    
    // MediaPipe s'active sur trigger pour MAX 5 secondes (15-20% batterie/h sinon)
    // Demande au FaceEngine de revérifier discrètement
    
    // Simule attente de 5s puis extinction si pas de fraude confirmée
    await Future.delayed(const Duration(seconds: 5));
    
    // Si la fraude était confirmée pendant ces 5s, AuthFailure aurait été dispatch et le vault re-locké
    _isCameraAwake = false;
  }
}
