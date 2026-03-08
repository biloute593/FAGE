import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/language_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const GestureFaceApp());
}

class GestureFaceApp extends StatelessWidget {
  const GestureFaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestureFace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8E4C9), // Beige accent
          secondary: Color(0xFFF5F5DC),
          surface: Color(0xFF131A2D), // Night Blue surface
          background: Color(0xFF0B1021), // Deep Night Blue background
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1021),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1021),
          foregroundColor: Color(0xFFE8E4C9),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFE8E4C9)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8E4C9),
            foregroundColor: const Color(0xFF0B1021),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF131A2D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white12, width: 1),
          ),
        ),
      ),
      home: const LanguageScreen(),
    );
  }
}
