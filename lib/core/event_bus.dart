import 'dart:async';

/// Enum représentant tous les événements circulant dans l'application.
enum AppEvent {
  sensorFrameReady,
  faceDetected,
  faceNotDetected,
  gestureDetected,
  gestureNotDetected,
  livenessConfirmed,
  livenessFailed,
  entropyValid,
  entropyInvalid,
  rppgSignalReady,
  correlationComputed,
  temporalTokenValid,
  temporalTokenExpired,
  fusionDecisionReady,
  authSuccess,
  authFailure,
  panicTriggered,
  tamperDetected,
  vaultLocked,
  vaultUnlocked,
  enrollmentSampleAdded,
  enrollmentModelUpdated,
  continuousAuthAlert,
  lockoutStarted,
  lockoutEnded,
}

/// Payload pour transmettre des données complexes via l'EventBus.
class EventPayload {
  final AppEvent type;
  final Map<String, dynamic> data;

  EventPayload(this.type, {this.data = const {}});
}

/// Bus d'événements interne pour la communication entre tous les modules (Moteur de Fusion, Camera, etc.)
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final StreamController<EventPayload> _controller = StreamController<EventPayload>.broadcast();

  /// Souscrire pour écouter tous les événements.
  Stream<EventPayload> get stream => _controller.stream;

  /// Diffuse un événement dans le système.
  void fire(AppEvent eventType, [Map<String, dynamic> data = const {}]) {
    _controller.add(EventPayload(eventType, data: data));
  }

  /// Écoute un événement spécifique.
  Stream<EventPayload> onEvent(AppEvent targetEvent) {
    return _controller.stream.where((event) => event.type == targetEvent);
  }

  void dispose() {
    _controller.close();
  }
}
