import 'dart:async';
import 'dart:ui';
import '../core/event_bus.dart';
import 'roi_manager.dart';

/// FrameSplitter - Simulated (no camera plugin required for build)
class FrameSplitter {
  final EventBus eventBus;
  final RoiManager roiManager;
  bool _isProcessing = false;

  FrameSplitter({required this.eventBus, required this.roiManager});

  void onImageFrame(dynamic image) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final faceBoundingBox = await roiManager.detectFaceBoundingBox(image);
      if (faceBoundingBox == null) {
        eventBus.fire(AppEvent.faceNotDetected);
        _isProcessing = false;
        return;
      }
      final zoneA = roiManager.createZoneA(image, faceBoundingBox);
      final zoneB = roiManager.createZoneB(image, faceBoundingBox);
      eventBus.fire(AppEvent.sensorFrameReady, {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'zoneA': zoneA,
        'zoneB': zoneB,
        'fullImage': image,
      });
    } catch (e) {
      // Silent error
    } finally {
      _isProcessing = false;
    }
  }
}
