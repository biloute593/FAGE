import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/event_bus.dart';
import '../core/constants.dart';

/// Audit Logger
/// Enregistre les événements de sécurité (authentifications, échecs, panic)
/// Chiffrés localement, non expédiés sur le cloud.
class AuditLogger {
  final EventBus eventBus;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _logKey = "gesture_face_audit_logs";

  AuditLogger({required this.eventBus}) {
    _listenEvents();
  }

  void _listenEvents() {
    eventBus.onEvent(AppEvent.authSuccess).listen((e) => _log("AUTH_SUCCESS", e.data));
    eventBus.onEvent(AppEvent.authFailure).listen((e) => _log("AUTH_FAILURE", e.data));
    eventBus.onEvent(AppEvent.panicTriggered).listen((e) => _log("PANIC_TRIGGERED", e.data));
    eventBus.onEvent(AppEvent.tamperDetected).listen((e) => _log("TAMPER_DETECTED", e.data));
    eventBus.onEvent(AppEvent.vaultUnlocked).listen((e) => _log("VAULT_ACCESS", e.data));
    eventBus.onEvent(AppEvent.lockoutStarted).listen((e) => _log("LOCKOUT_TRIGGERED", e.data));
  }

  Future<void> _log(String tag, Map<String, dynamic> data) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {'timestamp': timestamp, 'tag': tag, 'details': data};
    
    // Read existing
    String? existing = await _storage.read(key: _logKey);
    List<dynamic> logsList = [];
    if (existing != null) {
      logsList = jsonDecode(existing);
    }
    
    // Prepend new
    logsList.insert(0, logEntry);

    // Retention (Rétention : 90 jours puis purge automatique) - simulé ici par limite de taille 
    if (logsList.length > 500) {
      logsList = logsList.sublist(0, 500); 
    }

    // Save
    await _storage.write(key: _logKey, value: jsonEncode(logsList));
  }
}
