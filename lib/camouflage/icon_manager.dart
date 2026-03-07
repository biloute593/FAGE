import 'package:flutter/services.dart';

/// App Camouflage : Icon Manager
/// Permet à l'application de se faire passer pour un utilitaire banal
class IconManager {
  static const MethodChannel _channel = MethodChannel('com.gestureface.camouflage');

  /// Change l'icône de l'application (Dépendant de l'OS)
  /// Sous Android: Utilise un concept d'Alias d'Activité.
  /// Sous iOS: Utilise 'alternate icons API'.
  static Future<void> changeAppIcon(String type) async {
    try {
      // Types: 'calculator', 'weather', 'clock'
      await _channel.invokeMethod('changeIcon', {'iconName': type});
    } on PlatformException catch (e) {
      print("Failed to change icon: ${e.message}");
    }
  }

  /// Change le nom visible de l'application
  static Future<void> changeAppName(String newName) async {
    try {
       await _channel.invokeMethod('changeName', {'appName': newName});
    } on PlatformException catch (_) {
       // Ignoré au MVP
    }
  }
}
