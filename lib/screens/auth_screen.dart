import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;
  bool _authSuccess = false;
  String _statusText = 'Ready / Prêt';
  
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Camera error / Erreur caméra';
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _startAuth() async {
    if (_isAuthenticating || !_isCameraInitialized || _cameraController == null) return;
    
    setState(() {
      _isAuthenticating = true;
      _authSuccess = false;
      _statusText = 'Scanning for face... / Recherche de visage...';
    });

    int framesChecked = 0;
    bool faceFound = false;

    // Stream frames to verify a real face is present
    await _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessingFrame || faceFound || framesChecked >= 20) return;
      _isProcessingFrame = true;
      framesChecked++;

      try {
        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage == null) {
          _isProcessingFrame = false;
          return;
        }

        final List<Face> faces = await _faceDetector.processImage(inputImage);
        
        if (faces.isNotEmpty) {
          faceFound = true;
          await _cameraController!.stopImageStream();
          _handleSuccess();
        }
      } catch (e) {
        // ignore
      } finally {
        _isProcessingFrame = false;
      }
    });

    // Timeout fallback if no face found after ~3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (faceFound || !mounted) return;
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      setState(() {
        _isAuthenticating = false;
        _statusText = 'Failed: No face detected / Échec: Aucun visage détecté';
      });
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    const InputImageRotation imageRotation = InputImageRotation.rotation270deg;
    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  void _handleSuccess() async {
    if (!mounted) return;
    setState(() {
      _statusText = 'Face Detected! / Visage Détecté!';
      _authSuccess = true;
      _isAuthenticating = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color beige = Color(0xFFE8E4C9);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B1021),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _authSuccess ? Colors.green : beige.withOpacity(0.5),
                    width: _isAuthenticating ? 4 : 1,
                  ),
                ),
                child: ClipOval(
                  child: _isCameraInitialized
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform.scale(
                              scale: _cameraController!.value.aspectRatio,
                              child: Center(
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                            if (_isAuthenticating && !_authSuccess)
                              Container(
                                color: beige.withOpacity(0.1),
                              ),
                            if (_authSuccess)
                              Container(
                                color: Colors.green.withOpacity(0.2),
                                child: const Icon(Icons.check, size: 64, color: Colors.green),
                              ),
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(color: beige.withOpacity(0.5)),
                        ),
                ),
              ),
              
              const Spacer(),
              
              Text(
                _statusText,
                style: TextStyle(
                  fontSize: 16,
                  color: _authSuccess ? Colors.green : (_statusText.contains('Failed') ? Colors.red : beige.withOpacity(0.8)),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isAuthenticating || !_isCameraInitialized || _authSuccess) 
                      ? null 
                      : _startAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: beige,
                    foregroundColor: const Color(0xFF0B1021),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isAuthenticating ? 'WAIT / PATIENTER' : 'START / DÉMARRER',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
