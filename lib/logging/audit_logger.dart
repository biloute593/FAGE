import 'dart:convert';
import '../core/event_bus.dart';
import '../core/constants.dart';

/// AuditLogger - Simulated (no flutter_secure_storage plugin required)
/// Logs are kept in memory during the session for MVP
class AuditLogger {
  final EventBus eventBus;
  final List<Map<String, dynamic>> _logs = [];

  static const int _maxLogs = 500;

  AuditLogger({required this.eventBus}) {
    _listenEvents();
  }

  void _listenEvents() {
    eventBus.onEvent(AppEvent.authSuccess).listen((e) => _log('AUTH_SUCCESS', e.data));
    eventBus.onEvent(AppEvent.authFailure).listen((e) => _log('AUTH_FAILURE', e.data));
    eventBus.onEvent(AppEvent.panicTriggered).listen((e) => _log('PANIC_TRIGGERED', e.data));
    eventBus.onEvent(AppEvent.tamperDetected).listen((e) => _log('TAMPER_DETECTED', e.data));
    eventBus.onEvent(AppEvent.vaultUnlocked).listen((e) => _log('VAULT_ACCESS', e.data));
    eventBus.onEvent(AppEvent.lockoutStarted).listen((e) => _log('LOCKOUT_TRIGGERED', e.data));
  }

  void _log(String tag, Map<String, dynamic> data) {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'tag': tag,
      'details': data,
    };
    _logs.insert(0, entry);
    if (_logs.length > _maxLogs) _logs.removeRange(_maxLogs, _logs.length);
  }

  String exportLogs() => jsonEncode(_logs);

  List<Map<String, dynamic>> get recentLogs => List.unmodifiable(_logs);
}
