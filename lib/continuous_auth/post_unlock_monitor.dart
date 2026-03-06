import 'dart:async';
import '../core/event_bus.dart';
import 'trigger_detector.dart';

/// Post-Unlock Monitor
/// Auth Continue niveau 9 : Monitoring Léger Permanent (< 3% batterie/h)
class PostUnlockMonitor {
  final EventBus eventBus;
  final TriggerDetector triggerDetector;
  
  bool _isActive = false;

  PostUnlockMonitor({required this.eventBus, required this.triggerDetector});

  /// Appelé une fois que le vault est déverrouillé
  void startMonitoring() {
    if (_isActive) return;
    _isActive = true;
    
    // 1. Initialise les capteurs légers (Accéléromètre, Gyroscope)
    // 2. Transmet les signatures à TriggerDetector
    _startLightweightSensors();
  }

  void stopMonitoring() {
    _isActive = false;
    // Arrête les capteurs
  }

  void _startLightweightSensors() {
     // Simulation: Les données de l'IMU sont envoyées à ~50Hz
     Timer.periodic(const Duration(milliseconds: 20), (timer) {
       if (!_isActive) {
         timer.cancel();
         return;
       }
       
       triggerDetector.analyzeMotionData(
         ax: 0.0, ay: 9.8, az: 0.0, 
         gx: 0.0, gy: 0.0, gz: 0.0
       );
     });
  }
}
