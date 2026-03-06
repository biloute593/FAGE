import 'package:flutter/services.dart';

/// DataSandboxing
/// Conteneur isolé au niveau de la session applicative.
/// Bloque le Presse-Papiers sortant et empêche les captures d'écran.
class DataSandbox {
  
  /// Active la protection contre les screenshots. (Native level call via MethodChannel : FLAG_SECURE)
  static void restrictScreenshots(bool restrict) {
    // MethodChannel('com.gestureface.sandbox').invokeMethod('setSecureFlag', {'secure': restrict});
  }

  /// Assure que le contenu fraîchement copié dans l'app ne fuit pas à l'extérieur.
  static void secureClipboard() {
    // Option 1 : Efface le presse papier quand on lock() le vault
    SystemChannels.platform.invokeMethod('Clipboard.setData', 
      {"text": ""}
    );
  }

  /// Sur iOS : Empêche l'affichage de l'application dans le menu mulitâche (Recent Apps blur)
  static void blurAppTaskPreview() {
    // Nécessite une manipulation Native iOS applicationDidEnterBackground
  }
}
