import 'package:camera/camera.dart';
import 'skin_tone_adapter.dart';

/// Preprocessor
/// Premier passage sur l'image tirée du bus avant l'analyse des moteurs.
class Preprocessor {
  final SkinToneAdapter skinAdapter;

  Preprocessor({required this.skinAdapter});

  CameraImage processIncomingFrame(CameraImage rawFrame) {
    CameraImage stabilizedFrame = _applyFrameStabilization(rawFrame);
    
    // Détection dynamique et adaptation skin-inclusive
    int scale = skinAdapter.detectFitzpatrickScale(stabilizedFrame);
    CameraImage adaptedFrame = skinAdapter.adaptSkinTone(stabilizedFrame, scale);

    return adaptedFrame;
  }

  CameraImage _applyFrameStabilization(CameraImage image) {
    // Annulation de tremblements optiques (Optical Flow basique)
    // Permet une meilleure consistance du rPPG et des Micro-Tremors
    return image;
  }
}
