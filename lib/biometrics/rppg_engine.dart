import 'dart:async';
import '../core/event_bus.dart';
import '../core/constants.dart';
import '../core/feature_flags.dart';

/// rPPG Engine - Simulated (no camera plugin required)
class RppgEngine {
  final EventBus eventBus;

  RppgEngine({required this.eventBus});

  Future<void> evaluateRppgSignal(List<dynamic> croppedFaceFrames) async {
    if (!FeatureFlags.enableRppgMlModel) return;

    try {
      await Future.delayed(const Duration(milliseconds: 20));
      const confidence = 0.85;

      if (confidence > AppConstants.rppgConfidenceThreshold) {
        eventBus.fire(AppEvent.rppgSignalReady, {'confidence': confidence, 'status': 'valid'});
      } else {
        eventBus.fire(AppEvent.rppgSignalReady, {'confidence': confidence, 'status': 'low_confidence_ignored'});
      }
    } catch (e) {
      eventBus.fire(AppEvent.rppgSignalReady, {'status': 'error_ignored'});
    }
  }
}
