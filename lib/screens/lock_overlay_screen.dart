import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class LockOverlayScreen extends StatefulWidget {
  final String packageName;
  const LockOverlayScreen({super.key, required this.packageName});

  @override
  State<LockOverlayScreen> createState() => _LockOverlayScreenState();
}

class _LockOverlayScreenState extends State<LockOverlayScreen> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Simulate biometric scan for 2 seconds
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isAuthenticated = true;
      });
      // Close overlay and let user enter the app
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1021).withOpacity(0.95), // Semi-transparent
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAuthenticated ? Icons.check_circle : Icons.face,
              size: 100,
              color: _isAuthenticated ? Colors.green : const Color(0xFFE8E4C9),
            ),
            const SizedBox(height: 20),
            Text(
              _isAuthenticated ? 'Accès Autorisé' : 'Vérification Faciale...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isAuthenticated ? Colors.green : const Color(0xFFE8E4C9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Application: ${widget.packageName}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
