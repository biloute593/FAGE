import 'skin_tone_adapter.dart';

/// Preprocessor - Simulated (no camera plugin required)
class Preprocessor {
  final SkinToneAdapter skinAdapter;

  Preprocessor({required this.skinAdapter});

  dynamic processIncomingFrame(dynamic rawFrame) {
    final stabilizedFrame = _applyFrameStabilization(rawFrame);
    final scale = skinAdapter.detectFitzpatrickScale(stabilizedFrame);
    return skinAdapter.adaptSkinTone(stabilizedFrame, scale);
  }

  dynamic _applyFrameStabilization(dynamic image) {
    return image;
  }
}
