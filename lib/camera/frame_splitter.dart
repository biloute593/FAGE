import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:ui';
import '../core/event_bus.dart';
import 'roi_manager.dart';

/// Capture le flux caméra frontale (30fps) et gère le Dynamic ROI Splitter
class FrameSplitter {
  final EventBus eventBus;
  final RoiManager roiManager;
  
  bool _isProcessing = false;

  FrameSplitter({required this.eventBus, required this.roiManager});

  /// Appelé à chaque frame de la caméra
  void onImageFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;
    
    try {
      // 1. Détection rapide du visage pour Zone A
      final faceBoundingBox = await roiManager.detectFaceBoundingBox(image);
      
      if (faceBoundingBox == null) {
        eventBus.fire(AppEvent.faceNotDetected);
        _isProcessing = false;
        return;
      }
      
      // 2. Zone A : Visage + 15% marge
      final zoneA = roiManager.createZoneA(image, faceBoundingBox);
      
      // 3. Zone B : Le reste, orienté selon la main dominante de l'utilisateur
      final zoneB = roiManager.createZoneB(image, faceBoundingBox);
      
      // 4. Émettre l'événement que le frame est découpé et prêt pour l'analyse parallèle
      eventBus.fire(AppEvent.sensorFrameReady, {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'zoneA': zoneA,
        'zoneB': zoneB,
        'fullImage': image, // Utilisé pour le liveness global ou anti-adversarial si besoin
      });
      
    } catch (e) {
      // Gestion silencieuse des erreurs d'analyse de frame
    } finally {
      // Synchronisation de capture : on permet à la prochaine image d'être traitée
      _isProcessing = false;
    }
  }
}
