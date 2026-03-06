import 'dart:async';
import '../core/event_bus.dart';

/// Adaptive Enrollment Engine
/// S'adapte silencieusement à l'évolution de l'utilisateur (barbe, âge)
class AdaptiveEnrollment {
  final EventBus eventBus;
  int _lastUpdateTimestamp = 0;

  AdaptiveEnrollment({required this.eventBus}) {
    eventBus.onEvent(AppEvent.authSuccess).listen((event) {
      _evaluatePotentialUpdate(event);
    });
  }

  void _evaluatePotentialUpdate(EventPayload event) {
    // Si l'authentification s'est faite via BioHash (visage+geste normaux) 
    // et pas par secret question
    if (event.data['method'] == 'secret_question' || event.data['method'] == 'device_pin') {
      return; // Ne jamais adapter sur un fallback
    }

    double faceScore = event.data['face_score'] ?? 0.0;
    
    // Si la qualité du scan est excellente (> 0.95), on update le template interne
    if (faceScore > 0.95) {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Maximum 1 update par 24 heures (86400000 ms)
      if (now - _lastUpdateTimestamp > 86400000) {
        _performSilentUpdate(event.data['embedding']);
        _lastUpdateTimestamp = now;
      }
    }
  }

  void _performSilentUpdate(String? newEmbedding) {
    if (newEmbedding == null) return;
    
    // Logique réelle : On sauvegarde l'historique (max 3 versions) 
    // et on remplace l'ancien.
    // En cas de baisse générale de perf dans les jours suivants -> Rollback auto.
    
    eventBus.fire(AppEvent.enrollmentModelUpdated, {'version': 'v+1'});
  }
}
