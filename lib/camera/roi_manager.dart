import 'package:camera/camera.dart';
import 'dart:ui';

/// Contient la logique du Dynamic ROI Splitter (Region of Interest)
class RoiManager {
  // Configurable lors de l'inscription
  bool isRightHanded = true; 

  /// Détecte rapidement la bounding box du visage (simule BlazeFace via MediaPipe Tasks)
  Future<Rect?> detectFaceBoundingBox(CameraImage image) async {
    // TODO: Connect BlazeFace fast detection module here
    // Simulation du temps de traitement très rapide
    await Future.delayed(const Duration(milliseconds: 2));
    
    // Supposons que le visage est centré
    double width = image.width.toDouble();
    double height = image.height.toDouble();
    return Rect.fromCenter(
      center: Offset(width / 2, height / 2 - 50),
      width: width * 0.4,
      height: height * 0.3,
    );
  }

  /// Crée la Zone A : Bounding box du visage + 15% de marge
  Rect createZoneA(CameraImage image, Rect faceBox) {
    double widthMargin = faceBox.width * 0.15;
    double heightMargin = faceBox.height * 0.15;
    
    return Rect.fromLTRB(
      (faceBox.left - widthMargin).clamp(0, image.width.toDouble()),
      (faceBox.top - heightMargin).clamp(0, image.height.toDouble()),
      (faceBox.right + widthMargin).clamp(0, image.width.toDouble()),
      (faceBox.bottom + heightMargin).clamp(0, image.height.toDouble()),
    );
  }

  /// Crée la Zone B : Dédiée à la main. C'est l'espace restant, orienté
  /// Gaucher -> Zone B gauche, Droitier -> Zone B droite
  Rect createZoneB(CameraImage image, Rect faceBox) {
    if (isRightHanded) {
      // Main droite : la zone à droite du visage (du point de vue de l'utilisateur/miroir)
      // En caméra frontale, la droite de l'image est à gauche physiquement (si non mirrored)
      // Assumons image miroirs => droite physique = droite image
      return Rect.fromLTRB(
        faceBox.right,
        0,
        image.width.toDouble(),
        image.height.toDouble()
      );
    } else {
      // Main gauche
      return Rect.fromLTRB(
        0,
        0,
        faceBox.left,
        image.height.toDouble()
      );
    }
  }
}
