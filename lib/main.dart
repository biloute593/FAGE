import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/event_bus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<EventBus>(create: (_) => EventBus()),
      ],
      child: const GestureFaceApp(),
    ),
  );
}

class GestureFaceApp extends StatelessWidget {
  const GestureFaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestureFace',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      // Dummy home for now - Auth UI is silent
      home: const Scaffold(
        body: Center(
          child: Text('GestureFace v3.1 Background Authenticator'),
        ),
      ),
    );
  }
}
