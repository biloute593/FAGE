import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../core/event_bus.dart';
import '../core/constants.dart';

class GestureBiometricResult {
  final double gestureScore;
  final List<dynamic> landmarks; // 21 landmarks
  final String gestureSignature; 
  
  GestureBiometricResult({
    required this.gestureScore, 
    required this.landmarks, 
    required this.gestureSignature
  });
}

/// Gesture Recognition Engine (Zone B)
/// Gère MediaPipe Hand Landmarker (nouvelle API) et le Dynamic Gesture Field
class GestureEngine {
  final EventBus eventBus;
  StreamSubscription? _subscription;
  
  GestureEngine({required this.eventBus}) {
    _subscription = eventBus.onEvent(AppEvent.sensorFrameReady).listen((event) {
      _processFrame(event);
    });
  }

  Future<void> _processFrame(EventPayload event) async {
    final timestamp = event.data['timestamp'];
    final Rect zoneB = event.data['zoneB']; // ROI visée (Main)
    
    try {
      // 1. Extraction MediaPipe Hand Landmarker (21 landmarks)
      // Simulation appel TFLite : ~10ms
      await Future.delayed(const Duration(milliseconds: 10));
      final List<dynamic> landmarks = _simulateHandLandmarks();
      
      // Calcul du score de visibilité de la main (< 0.70 => on rejette, "Ajustez main")
      double handVisibilityScore = 0.85; 
      if (handVisibilityScore < 0.70) {
        eventBus.fire(AppEvent.gestureNotDetected, {'timestamp': timestamp, 'reason': 'low_visibility'});
        return;
      }

      // 2. Calcul du Dynamic Gesture Field (Angles, Vitesse, Trajectoire)
      // On compare la "signature" à celle enregistrée. Pas juste un geste statique.
      String dynamicSignature = _computeDynamicGestureField(landmarks);
      
      // 3. Calcul du Gesture Score
      double gestureScore = 0.94; // Simulé
      
      if (gestureScore > AppConstants.gestureScoreThreshold) {
         eventBus.fire(AppEvent.gestureDetected, {
           'timestamp': timestamp,
           'result': GestureBiometricResult(
             gestureScore: gestureScore,
             landmarks: landmarks,
             gestureSignature: dynamicSignature,
           )
         });
      } else {
         eventBus.fire(AppEvent.gestureNotDetected, {'timestamp': timestamp});
      }

    } catch (e) {
      debugPrint("GestureEngine Error: $e");
      eventBus.fire(AppEvent.gestureNotDetected, {'timestamp': timestamp});
    }
  }

  List<dynamic> _simulateHandLandmarks() {
    // Simule 21 points 3D pour la main
    return List.generate(21, (index) => {"x": 0.0, "y": 0.0, "z": 0.0});
  }

  String _computeDynamicGestureField(List<dynamic> landmarks) {
    // Simulation: calcul Angles entre phalanges, Vecteur vélocité, Position spatiale
    return "dynamic_gesture_signature_v1";
  }

  void dispose() {
    _subscription?.cancel();
  }
}
