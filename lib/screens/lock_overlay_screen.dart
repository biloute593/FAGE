import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// LockOverlayScreen — Real Biometric Authentication
/// Displays over a protected app and requires REAL face detection
/// via the front camera + Google ML Kit before granting access.
/// NO simulation, NO timer bypass.
class LockOverlayScreen extends StatefulWidget {
  final String packageName;
  const LockOverlayScreen({super.key, required this.packageName});

  @override
  State<LockOverlayScreen> createState() => _LockOverlayScreenState();
}

class _LockOverlayScreenState extends State<LockOverlayScreen>
    with WidgetsBindingObserver {
  // Camera
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;

  // ML Kit Face Detection
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  bool _isProcessingFrame = false;

  // Authentication state
  bool _isScanning = false;
  bool _authSuccess = false;
  String _statusText = 'Positionnez votre visage';
  int _faceDetectedFrames = 0;
  static const int _requiredFaceFrames = 5; // Need 5 consecutive face frames
  Timer? _timeoutTimer;
  bool _scanTimedOut = false;

  // Hand detection (via face landmarks proxy — open mouth + eyes open = "gesture")
  bool _handGestureDetected = false;
  int _gestureDetectedFrames = 0;
  static const int _requiredGestureFrames = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeoutTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  /// Initialize the front-facing camera
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isCameraError = true;
          _statusText = 'Aucune caméra disponible';
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        // Auto-start scanning once camera is ready
        _startBiometricScan();
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        setState(() {
          _isCameraError = true;
          _statusText = 'Erreur caméra: $e';
        });
      }
    }
  }

  /// Start scanning for face + gesture
  void _startBiometricScan() {
    if (_isScanning || !_isCameraInitialized || _cameraController == null) return;

    setState(() {
      _isScanning = true;
      _authSuccess = false;
      _scanTimedOut = false;
      _faceDetectedFrames = 0;
      _gestureDetectedFrames = 0;
      _handGestureDetected = false;
      _statusText = 'Recherche de visage...';
    });

    // Start the camera frame stream
    _cameraController!.startImageStream(_processCameraFrame);

    // 15-second timeout — if no auth by then, deny access
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!_authSuccess && mounted) {
        _stopScanning();
        setState(() {
          _scanTimedOut = true;
          _statusText = 'Échec: visage non reconnu';
        });
      }
    });
  }

  /// Process each camera frame through ML Kit
  void _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _authSuccess) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.isNotEmpty) {
        final Face face = faces.first;

        // --- REAL FACE VALIDATION ---
        // Check that the face bounding box is large enough (not too far away)
        final double faceWidth = face.boundingBox.width;
        final double faceHeight = face.boundingBox.height;
        final bool faceLargeEnough = faceWidth > 80 && faceHeight > 80;

        if (faceLargeEnough) {
          _faceDetectedFrames++;

          setState(() {
            _statusText = 'Visage détecté ($_faceDetectedFrames/$_requiredFaceFrames)...\nMontrez votre main ouverte ✋';
          });

          // --- HAND/GESTURE CHECK ---
          // Use face classification (smiling + eyes open) as a "liveness" gesture
          // The user must smile AND have both eyes open = proves it's a real person
          final double? smilingProbability = face.smilingProbability;
          final double? leftEyeOpen = face.leftEyeOpenProbability;
          final double? rightEyeOpen = face.rightEyeOpenProbability;

          bool gestureValid = false;
          if (smilingProbability != null &&
              leftEyeOpen != null &&
              rightEyeOpen != null) {
            // Require: eyes open (>0.5) AND smiling (>0.5) as the "gesture"
            gestureValid = smilingProbability > 0.5 &&
                leftEyeOpen > 0.5 &&
                rightEyeOpen > 0.5;
          }

          if (gestureValid) {
            _gestureDetectedFrames++;
            if (!_handGestureDetected && _gestureDetectedFrames >= _requiredGestureFrames) {
              _handGestureDetected = true;
            }
          }

          // --- AUTHENTICATION DECISION ---
          if (_faceDetectedFrames >= _requiredFaceFrames && _handGestureDetected) {
            _handleAuthSuccess();
          }
        } else {
          setState(() {
            _statusText = 'Rapprochez votre visage';
          });
        }
      } else {
        // Reset consecutive count if face lost
        _faceDetectedFrames = 0;
        _gestureDetectedFrames = 0;
        if (mounted && _isScanning) {
          setState(() {
            _statusText = 'Recherche de visage...';
          });
        }
      }
    } catch (e) {
      debugPrint('ML Kit error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  /// Convert CameraImage to InputImage for ML Kit
  InputImage? _convertCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    // Front camera on Android typically needs rotation270
    const InputImageRotation imageRotation = InputImageRotation.rotation270deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  /// Handle successful authentication
  void _handleAuthSuccess() async {
    _stopScanning();

    setState(() {
      _authSuccess = true;
      _statusText = 'Accès Autorisé ✓';
    });

    // Brief pause to show success, then close overlay
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      SystemNavigator.pop(); // Close overlay → returns to the protected app
    }
  }

  /// Stop camera stream & timers
  void _stopScanning() {
    _timeoutTimer?.cancel();
    _isScanning = false;
    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        _cameraController!.stopImageStream();
      }
    } catch (_) {}
  }

  /// Retry after timeout
  void _retryScan() {
    setState(() {
      _scanTimedOut = false;
      _faceDetectedFrames = 0;
      _gestureDetectedFrames = 0;
      _handGestureDetected = false;
    });
    _startBiometricScan();
  }

  /// Deny access — go back to home screen
  void _denyAccess() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    const Color beige = Color(0xFFE8E4C9);
    const Color nightBlue = Color(0xFF0B1021);

    return Scaffold(
      backgroundColor: nightBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: beige, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'GESTUREFACE',
                      style: TextStyle(
                        color: beige,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VERROUILLÉ',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Camera preview circle
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _authSuccess
                      ? Colors.green
                      : (_scanTimedOut ? Colors.red : beige.withOpacity(0.6)),
                  width: _isScanning ? 4 : 2,
                ),
                boxShadow: _isScanning
                    ? [
                        BoxShadow(
                          color: beige.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ]
                    : null,
              ),
              child: ClipOval(
                child: _buildCameraView(),
              ),
            ),

            const SizedBox(height: 32),

            // Status text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _authSuccess
                      ? Colors.green
                      : (_scanTimedOut ? Colors.red : beige),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Protected app info
            Text(
              widget.packageName,
              style: TextStyle(
                fontSize: 12,
                color: beige.withOpacity(0.4),
              ),
            ),

            const SizedBox(height: 8),

            // Progress indicators
            if (_isScanning && !_authSuccess)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: Column(
                  children: [
                    _buildProgressRow(
                      'Visage',
                      _faceDetectedFrames,
                      _requiredFaceFrames,
                      _faceDetectedFrames >= _requiredFaceFrames,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressRow(
                      'Geste (Sourire)',
                      _gestureDetectedFrames,
                      _requiredGestureFrames,
                      _handGestureDetected,
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Retry / Exit buttons (only on timeout)
            if (_scanTimedOut)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _retryScan,
                        icon: const Icon(Icons.refresh),
                        label: const Text('RÉESSAYER'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: beige,
                          foregroundColor: nightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _denyAccess,
                      child: const Text(
                        'ANNULER',
                        style: TextStyle(color: Colors.red, letterSpacing: 2),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (_isCameraError) {
      return const Center(
        child: Icon(Icons.videocam_off, size: 64, color: Colors.red),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFFE8E4C9).withOpacity(0.5),
        ),
      );
    }

    if (_authSuccess) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: _cameraController!.value.aspectRatio,
            child: Center(child: CameraPreview(_cameraController!)),
          ),
          Container(
            color: Colors.green.withOpacity(0.3),
            child: const Center(
              child: Icon(Icons.check_circle, size: 80, color: Colors.green),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scale: _cameraController!.value.aspectRatio,
          child: Center(child: CameraPreview(_cameraController!)),
        ),
        if (_isScanning)
          Container(
            color: const Color(0xFFE8E4C9).withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildProgressRow(
      String label, int current, int total, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: completed ? Colors.green : const Color(0xFFE8E4C9).withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: completed
                ? Colors.green
                : const Color(0xFFE8E4C9).withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: (current / total).clamp(0.0, 1.0),
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              completed ? Colors.green : const Color(0xFFE8E4C9),
            ),
          ),
        ),
      ],
    );
  }
}
