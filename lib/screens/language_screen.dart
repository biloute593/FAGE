import 'package:flutter/material.dart';
import 'auth_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void _selectLanguage(BuildContext context, String languageCode) {
    // In a real app we'd save the locale. Here we just navigate.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.language,
                  size: 64,
                  color: Color(0xFFE8E4C9),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Choose Language\nChoisir la langue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFFE8E4C9),
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 64),
                _LanguageButton(
                  title: 'Français',
                  onTap: () => _selectLanguage(context, 'fr'),
                ),
                const SizedBox(height: 16),
                _LanguageButton(
                  title: 'English',
                  onTap: () => _selectLanguage(context, 'en'),
                ),
                const SizedBox(height: 16),
                _LanguageButton(
                  title: 'Español',
                  onTap: () => _selectLanguage(context, 'es'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LanguageButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE8E4C9),
          side: const BorderSide(color: Color(0xFFE8E4C9), width: 1),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
