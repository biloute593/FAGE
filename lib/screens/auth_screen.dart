import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
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
    super.dispose();
  }

  Future<void> _startAuth() async {
    if (_isAuthenticating || !_isCameraInitialized) return;
    
    setState(() {
      _isAuthenticating = true;
      _authSuccess = false;
      _statusText = 'Scanning... / Analyse en cours...';
    });

    // Simulate recording face and gesture
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    setState(() {
      _statusText = 'Success / Succès';
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
              
              // Minimalist Camera Preview
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
                            if (_isAuthenticating)
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
                  color: _authSuccess ? Colors.green : beige.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
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
