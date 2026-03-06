import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/event_bus.dart';
import '../core/constants.dart';
import '../core/feature_flags.dart';

/// Fusion Engine — Constant Time Processing
/// Décide du sort de la tentative d'accès. 
/// Gère la mitigation des attaques temporelles via Padding.
class FusionEngine {
  final EventBus eventBus;

  // Variables accumulées pendant la session (1200ms max)
  bool _faceValid = false;
  bool _gestureValid = false;
  bool _livenessValid = false;
  bool _entropyValid = false;
  bool _temporalTokenValid = true; // Vérifié en amont
  bool _rppgValid = false; // Optionnel MVP

  int _sessionStartTime = 0;

  FusionEngine({required this.eventBus}) {
    _initListeners();
  }

  void _initListeners() {
    eventBus.onEvent(AppEvent.faceDetected).listen((_) => _faceValid = true);
    eventBus.onEvent(AppEvent.gestureDetected).listen((_) => _gestureValid = true);
    eventBus.onEvent(AppEvent.livenessConfirmed).listen((_) => _livenessValid = true);
    eventBus.onEvent(AppEvent.entropyValid).listen((_) => _entropyValid = true);
    
    eventBus.onEvent(AppEvent.rppgSignalReady).listen((event) {
       if (event.data['confidence'] > AppConstants.rppgConfidenceThreshold) {
         _rppgValid = true;
       }
    });

    eventBus.onEvent(AppEvent.sensorFrameReady).listen((event) {
       if (_sessionStartTime == 0) {
         _sessionStartTime = DateTime.now().millisecondsSinceEpoch;
         // Initialize la fenêtre de décision
         _scheduleDecision(); 
       }
    });
  }

  void _scheduleDecision() {
    // La réponse DOIT être à T+1200ms exactement
    Timer(const Duration(milliseconds: AppConstants.constantProcessingTimeMs), () {
      _evaluateAndDispatch();
    });
  }

  void _evaluateAndDispatch() {
    
    // Conditions MVP TOUTES requises
    bool isAuthorized = true;

    if (!_faceValid) isAuthorized = false;
    if (!_gestureValid) isAuthorized = false;
    if (!_livenessValid) isAuthorized = false;
    if (!_entropyValid) isAuthorized = false;
    if (!_temporalTokenValid) isAuthorized = false;

    // RPPG Conditionnel
    if (FeatureFlags.enableRppgMlModel && FeatureFlags.isRppgBlocking) {
      if (!_rppgValid) isAuthorized = false;
    }

    // Corrélation V2 (désactivée au MVP)
    if (FeatureFlags.enableMicroMotionCorrelationEngine) {
      // isAuthorized = isAuthorized && _correlationValid;
    }

    if (isAuthorized) {
      eventBus.fire(AppEvent.authSuccess, {'timestamp': DateTime.now().millisecondsSinceEpoch});
    } else {
      eventBus.fire(AppEvent.authFailure, {'reason': 'fusion_conditions_unmet'});
    }

    _resetSession();
  }

  void _resetSession() {
    _faceValid = false;
    _gestureValid = false;
    _livenessValid = false;
    _entropyValid = false;
    _rppgValid = false;
    _sessionStartTime = 0;
  }
}
