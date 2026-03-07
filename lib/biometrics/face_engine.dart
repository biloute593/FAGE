import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/event_bus.dart';
import '../core/constants.dart';

class FaceBiometricResult {
  final double faceScore;
  final List<dynamic> landmarks;
  final String embedding;

  FaceBiometricResult({
    required this.faceScore,
    required this.landmarks,
    required this.embedding,
  });
}

/// FaceEngine - Simulated face recognition (no native MediaPipe required)
class FaceEngine {
  final EventBus eventBus;
  StreamSubscription? _subscription;

  FaceEngine({required this.eventBus}) {
    _subscription = eventBus.onEvent(AppEvent.sensorFrameReady).listen((event) {
      _processFrame(event);
    });
  }

  Future<void> _processFrame(EventPayload event) async {
    final timestamp = event.data['timestamp'];
    try {
      await Future.delayed(const Duration(milliseconds: 8));
      final landmarks = List.generate(478, (_) => {'x': 0.0, 'y': 0.0, 'z': 0.0});
      await Future.delayed(const Duration(milliseconds: 12));
      const embedding = 'simulated_embedding';
      const faceScore = 0.95;

      if (faceScore > AppConstants.faceScoreThreshold) {
        eventBus.fire(AppEvent.faceDetected, {
          'timestamp': timestamp,
          'result': FaceBiometricResult(
            faceScore: faceScore,
            landmarks: landmarks,
            embedding: embedding,
          ),
        });
      } else {
        eventBus.fire(AppEvent.faceNotDetected, {'timestamp': timestamp});
      }
    } catch (e) {
      debugPrint('FaceEngine Error: $e');
      eventBus.fire(AppEvent.faceNotDetected, {'timestamp': timestamp});
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
