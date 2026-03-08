import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'dashboard_screen.dart';
import 'enrollment_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  bool _faceScan = false;
  bool _gestureScan = false;
  bool _authSuccess = false;
  String _statusText = 'Initialisation de la caméra...';
  
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
          _statusText = 'Prêt pour l\'authentification\nPositionnez votre visage';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Erreur d\'accès à la caméra';
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAuth() async {
    if (_isAuthenticating || !_isCameraInitialized) return;
    
    setState(() {
      _isAuthenticating = true;
      _faceScan = false;
      _gestureScan = false;
      _authSuccess = false;
      _statusText = 'Analyse biométrique en cours...';
    });

    // Simulated real-time scan duration while camera is streaming
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _faceScan = true;
      _statusText = 'Visage reconnu ✓\nAnalyse du geste...';
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _gestureScan = true;
      _statusText = 'Geste reconnu ✓\nAuthentification réussie !';
      _authSuccess = true;
      _isAuthenticating = false;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Text(
                      'Scan Biométrique',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Technologie GestureFace active',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),

              // Central Live Camera Scanner
              Column(
                children: [
                  ScaleTransition(
                    scale: _isAuthenticating ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: GestureDetector(
                      onTap: _startAuth,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _authSuccess
                                ? const Color(0xFF03DAC6)
                                : _isAuthenticating
                                    ? const Color(0xFF6C63FF)
                                    : Colors.white24,
                            width: 3,
                          ),
                          boxShadow: _isAuthenticating || _authSuccess
                              ? [
                                  BoxShadow(
                                    color: (_authSuccess
                                            ? const Color(0xFF03DAC6)
                                            : const Color(0xFF6C63FF))
                                        .withOpacity(0.5),
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  )
                                ]
                              : [],
                        ),
                        child: ClipOval(
                          child: _isCameraInitialized
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Transform.scale(
                                      // Scale to fill circle
                                      scale: _cameraController!.value.aspectRatio,
                                      child: Center(
                                        child: CameraPreview(_cameraController!),
                                      ),
                                    ),
                                    if (_isAuthenticating)
                                      Container(
                                        color: const Color(0xFF6C63FF).withOpacity(0.2), // Scanner overlay
                                      ),
                                    if (_authSuccess)
                                      Container(
                                        color: const Color(0xFF03DAC6).withOpacity(0.4),
                                        child: const Icon(Icons.check, size: 80, color: Colors.white),
                                      ),
                                  ],
                                )
                              : const Center(
                                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _authSuccess
                          ? const Color(0xFF03DAC6)
                          : Colors.white.withOpacity(0.8),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Status chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatusChip(
                        label: 'Visage',
                        icon: Icons.face,
                        active: _faceScan,
                      ),
                      const SizedBox(width: 16),
                      _StatusChip(
                        label: 'Geste',
                        icon: Icons.pan_tool,
                        active: _gestureScan,
                      ),
                    ],
                  ),
                ],
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_isAuthenticating || !_isCameraInitialized) ? null : _startAuth,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(_isAuthenticating
                            ? 'Analyse en cours...'
                            : 'Démarrer l\'analyse'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EnrollmentScreen()),
                        );
                      },
                      child: Text(
                        'Première utilisation ? S\'inscrire',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF03DAC6).withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active ? const Color(0xFF03DAC6) : Colors.white24,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : icon,
            size: 18,
            color: active ? const Color(0xFF03DAC6) : Colors.white38,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF03DAC6) : Colors.white38,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
