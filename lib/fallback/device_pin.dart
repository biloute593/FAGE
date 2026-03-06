import 'package:flutter/services.dart';
import '../core/event_bus.dart';

/// Fallback Ultime : Device PIN (BiometricManager/LocalAuthentication)
/// INVISIBLE avant 5 échecs biométriques et 3 échecs question secrète.
class DevicePinFallback {
  final EventBus eventBus;

  DevicePinFallback({required this.eventBus});

  /// Demande l'authentification native du système OS
  Future<void> requestDeviceAuth() async {
    try {
      // Simulation: Appel au framework LocalAuthentication sur iOS ou BiometricManager sur Android
      // localAuth.authenticate(localizedReason: 'Accès GestureFace', fallback: true);
      
      bool authenticated = await _simulateNativeDeviceAuth();

      if (authenticated) {
        eventBus.fire(AppEvent.authSuccess, {'method': 'device_pin'});
      } else {
        eventBus.fire(AppEvent.authFailure, {'reason': 'device_pin_failed'});
      }
    } on PlatformException catch (_) {
      eventBus.fire(AppEvent.authFailure, {'reason': 'device_pin_error'});
    }
  }

  Future<bool> _simulateNativeDeviceAuth() async {
    return true; // Simule un succès du code PIN du téléphone
  }
}
