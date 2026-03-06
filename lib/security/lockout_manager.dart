import 'dart:async';
import '../core/event_bus.dart';
import '../core/constants.dart';

/// Lockout Manager
/// Protège contre le brute force physique.
class LockoutManager {
  final EventBus eventBus;
  int _consecutiveFailures = 0;
  DateTime? _lockoutUntil;
  StreamSubscription? _subscription;

  LockoutManager({required this.eventBus}) {
    _subscription = eventBus.onEvent(AppEvent.authFailure).listen((_) {
      _recordFailure();
    });

    eventBus.onEvent(AppEvent.authSuccess).listen((_) {
      _reset();
    });
  }

  void _recordFailure() {
    _consecutiveFailures++;

    if (_consecutiveFailures == AppConstants.lockoutThreshold2) { // 5 lockouts -> 30 mins
      _triggerLockout(AppConstants.lockoutDurationsMinutes[1]);
    } else if (_consecutiveFailures == AppConstants.lockoutThreshold1) { // 3 lockouts -> 5 mins
      _triggerLockout(AppConstants.lockoutDurationsMinutes[0]);
    }
  }

  void _triggerLockout(int minutes) {
    _lockoutUntil = DateTime.now().add(Duration(minutes: minutes));
    eventBus.fire(AppEvent.lockoutStarted, {
      'duration_minutes': minutes,
      'until': _lockoutUntil?.millisecondsSinceEpoch
    });
  }

  bool isLockedOut() {
    if (_lockoutUntil == null) return false;
    
    if (DateTime.now().isAfter(_lockoutUntil!)) {
      eventBus.fire(AppEvent.lockoutEnded);
      _lockoutUntil = null;
      return false;
    }
    return true;
  }

  void _reset() {
    _consecutiveFailures = 0;
    _lockoutUntil = null;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
