import 'dart:async';
import '../core/event_bus.dart';
import '../camera/frame_splitter.dart';
import '../biometrics/face_engine.dart';
import '../biometrics/gesture_engine.dart';
import '../biometrics/liveness_engine.dart';
import '../biometrics/entropy_scorer.dart';
import '../auth/fusion_engine.dart';
import '../security/anti_adversarial.dart';
import '../security/integrity_monitor.dart';

/// Authentication Orchestrator
/// Câble ensemble tous les sous-moteurs biométriques et l'Event Bus
class AuthenticationOrchestrator {
  final EventBus eventBus;
  final FrameSplitter frameSplitter;
  final FaceEngine faceEngine;
  final GestureEngine gestureEngine;
  final LivenessEngine livenessEngine;
  final EntropyScorer entropyScorer;
  final FusionEngine fusionEngine;
  final AntiAdversarial antiAdversarial;
  final IntegrityMonitor integrityMonitor;

  AuthenticationOrchestrator({
    required this.eventBus,
    required this.frameSplitter,
    required this.faceEngine,
    required this.gestureEngine,
    required this.livenessEngine,
    required this.entropyScorer,
    required this.fusionEngine,
    required this.antiAdversarial,
    required this.integrityMonitor,
  });

  /// Démarre une session d'authentification après vérification d'intégrité
  Future<void> startSession() async {
    bool isSystemSecure = await integrityMonitor.checkSystemIntegrity();
    
    if (!isSystemSecure) {
      // Vault bloqué, menace enregistrée, auth annulée
      return;
    }

    // Connecte logic flow :
    // - FrameSplitter génère AppEvent.sensorFrameReady
    // - FaceEngine et GestureEngine l'écoutent en parallèle (via leurs init)
    // - LivenessEngine et EntropyScorer font leurs vérifications asynchrone
    // - Fusion Engine gère le chronomètre constant de 1200ms
  }

  void stopSession() {
    // Purge logic & stop engines
  }
}
