import 'package:flutter/material.dart';
import 'dart:async';
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
  String _statusText = 'Appuyez pour démarrer l\'authentification';
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAuth() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _faceScan = false;
      _gestureScan = false;
      _authSuccess = false;
      _statusText = 'Analyse du visage...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _faceScan = true;
      _statusText = 'Visage reconnu ✓\nAnalyse du geste...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _gestureScan = true;
      _statusText = 'Geste reconnu ✓\nAuthentification réussie !';
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
                      'Authentification',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Double facteur biométrique',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),

              // Central scanner
              Column(
                children: [
                  ScaleTransition(
                    scale: _isAuthenticating ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: GestureDetector(
                      onTap: _startAuth,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _authSuccess
                                ? const Color(0xFF03DAC6)
                                : _isAuthenticating
                                    ? const Color(0xFF6C63FF)
                                    : Colors.white24,
                            width: 2,
                          ),
                          boxShadow: _isAuthenticating || _authSuccess
                              ? [
                                  BoxShadow(
                                    color: (_authSuccess
                                            ? const Color(0xFF03DAC6)
                                            : const Color(0xFF6C63FF))
                                        .withOpacity(0.4),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  )
                                ]
                              : [],
                        ),
                        child: Icon(
                          _authSuccess
                              ? Icons.check_circle_outline
                              : Icons.face_retouching_natural,
                          size: 100,
                          color: _authSuccess
                              ? const Color(0xFF03DAC6)
                              : _isAuthenticating
                                  ? const Color(0xFF6C63FF)
                                  : Colors.white38,
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
                          : Colors.white.withOpacity(0.7),
                      height: 1.5,
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
                        onPressed: _isAuthenticating ? null : _startAuth,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(_isAuthenticating
                            ? 'Authentification en cours...'
                            : 'Démarrer l\'authentification'),
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
