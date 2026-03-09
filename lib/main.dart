import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/lock_overlay_screen.dart';
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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/lock_overlay') {
          final args = settings.arguments as Map<String, dynamic>?;
          final packageName = args?['packageName'] ?? 'Unknown App';
          return MaterialPageRoute(
            builder: (context) => LockOverlayScreen(packageName: packageName),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        );
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const platform = MethodChannel('com.gestureface/applocker');
  List<AppInfo> _apps = [];
  List<String> _protectedAppPackages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProtectedApps();
    _loadInstalledApps();
  }

  Future<void> _loadProtectedApps() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _protectedAppPackages = prefs.getStringList('protectedApps') ?? [];
    });
  }

  Future<void> _loadInstalledApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
        
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    
    setState(() {
      _apps = apps;
      _isLoading = false;
    });
  }

  Future<void> _toggleAppProtection(String packageName, bool protect) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (protect) {
        if (!_protectedAppPackages.contains(packageName)) {
          _protectedAppPackages.add(packageName);
        }
      } else {
        _protectedAppPackages.remove(packageName);
      }
    });
    
    await prefs.setStringList('protectedApps', _protectedAppPackages);
    // Send updated list to native service
    try {
      await platform.invokeMethod('updateProtectedApps', {'apps': _protectedAppPackages});
    } catch (e) {
      debugPrint("Failed to update native protective apps: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GestureFace Locker'),
        actions: [
            IconButton(
              icon: const Icon(Icons.security, color: Colors.green),
              onPressed: () async {
                  try {
                    await platform.invokeMethod('startMonitorService');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service Démarré!')),
                      );
                    }
                  } on PlatformException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: ${e.message}')),
                      );
                    }
                  }
              },
            )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                final app = _apps[index];
                final isProtected = _protectedAppPackages.contains(app.packageName);
                
                return ListTile(
                  leading: app.icon != null
                      ? Image.memory(app.icon!, width: 40, height: 40)
                      : const Icon(Icons.android),
                  title: Text(app.name),
                  subtitle: Text(app.packageName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  trailing: Switch(
                    value: isProtected,
                    onChanged: (value) => _toggleAppProtection(app.packageName, value),
                    activeColor: const Color(0xFFE8E4C9),
                  ),
                );
              },
            ),
    );
  }
}
