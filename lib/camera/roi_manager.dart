import 'dart:ui';

/// RoiManager - Simulated (no camera plugin required)
class RoiManager {
  bool isRightHanded = true;

  Future<Rect?> detectFaceBoundingBox(dynamic image) async {
    await Future.delayed(const Duration(milliseconds: 2));
    // Simulated face bounding box: center of the frame
    return Rect.fromCenter(
      center: const Offset(320, 190),
      width: 256,
      height: 192,
    );
  }

  Rect createZoneA(dynamic image, Rect faceBox) {
    final widthMargin = faceBox.width * 0.15;
    final heightMargin = faceBox.height * 0.15;
    return Rect.fromLTRB(
      (faceBox.left - widthMargin).clamp(0, 640),
      (faceBox.top - heightMargin).clamp(0, 480),
      (faceBox.right + widthMargin).clamp(0, 640),
      (faceBox.bottom + heightMargin).clamp(0, 480),
    );
  }

  Rect createZoneB(dynamic image, Rect faceBox) {
    if (isRightHanded) {
      return Rect.fromLTRB(faceBox.right, 0, 640, 480);
    } else {
      return Rect.fromLTRB(0, 0, faceBox.left, 480);
    }
  }
}
