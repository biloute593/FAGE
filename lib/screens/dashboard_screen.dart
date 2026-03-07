import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'vault_screen.dart';
import 'enrollment_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    VaultScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121F),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_outlined),
              activeIcon: Icon(Icons.lock),
              label: 'Coffre',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Réglages',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _monitoring = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GestureFace',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tableau de bord',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03DAC6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF03DAC6).withOpacity(0.4)),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF03DAC6),
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Security Status Card
            _SecurityStatusCard(monitoring: _monitoring),
            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _QuickActionCard(
                  icon: Icons.face_retouching_natural,
                  title: 'Ré-analyser',
                  subtitle: 'Authentification',
                  color: const Color(0xFF6C63FF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.person_add_alt_1,
                  title: 'Inscrire',
                  subtitle: 'Biométrie',
                  color: const Color(0xFF03DAC6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EnrollmentScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: _monitoring ? Icons.pause_circle : Icons.play_circle,
                  title: _monitoring ? 'Arrêter' : 'Démarrer',
                  subtitle: 'Surveillance',
                  color: _monitoring
                      ? Colors.orange
                      : Colors.green,
                  onTap: () {
                    setState(() => _monitoring = !_monitoring);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_monitoring
                            ? 'Surveillance continue activée'
                            : 'Surveillance arrêtée'),
                        backgroundColor: _monitoring
                            ? Colors.green
                            : Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.history,
                  title: 'Journaux',
                  subtitle: 'Activité',
                  color: Colors.amber,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LogsScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Feature List
            const Text(
              'Modules de sécurité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _FeatureRow(
              icon: Icons.face,
              title: 'Reconnaissance faciale',
              subtitle: 'MediaPipe + ArcFace',
              status: 'Actif',
              statusColor: Colors.green,
            ),
            _FeatureRow(
              icon: Icons.pan_tool,
              title: 'Détection de geste',
              subtitle: 'Hand Landmarker',
              status: 'Actif',
              statusColor: Colors.green,
            ),
            _FeatureRow(
              icon: Icons.security,
              title: 'Détection Liveness',
              subtitle: 'Anti-spoofing FFT',
              status: 'Actif',
              statusColor: Colors.green,
            ),
            _FeatureRow(
              icon: Icons.warning_amber,
              title: 'Mode Panic',
              subtitle: 'Geste de détresse',
              status: 'Prêt',
              statusColor: Colors.amber,
            ),
            _FeatureRow(
              icon: Icons.lock,
              title: 'Coffre chiffré',
              subtitle: 'AES-256-GCM',
              status: 'Sécurisé',
              statusColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  final bool monitoring;
  const _SecurityStatusCard({required this.monitoring});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statut de sécurité',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Système protégé',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                monitoring ? '● Surveillance active' : '○ Surveillance inactive',
                style: TextStyle(
                  color: monitoring ? Colors.greenAccent : Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.verified_user,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Logs screen
class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  static final List<Map<String, String>> _logs = [
    {'time': '22:15:03', 'event': 'Auth réussie', 'detail': 'Visage + Geste OK', 'type': 'success'},
    {'time': '22:14:58', 'event': 'Scan visage', 'detail': 'Score: 0.97', 'type': 'info'},
    {'time': '22:14:55', 'event': 'Scan geste', 'detail': 'Score: 0.94', 'type': 'info'},
    {'time': '21:32:11', 'event': 'Auth réussie', 'detail': 'Visage + Geste OK', 'type': 'success'},
    {'time': '20:11:44', 'event': 'Tentative échouée', 'detail': 'Score visage trop bas', 'type': 'warning'},
    {'time': '20:11:32', 'event': 'Lockout: 30s', 'detail': 'Trop de tentatives', 'type': 'error'},
    {'time': '19:05:20', 'event': 'Système démarré', 'detail': 'Intégrité vérifiée', 'type': 'info'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journaux d\'activité'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, i) {
          final log = _logs[i];
          final color = log['type'] == 'success'
              ? Colors.green
              : log['type'] == 'error'
                  ? Colors.red
                  : log['type'] == 'warning'
                      ? Colors.amber
                      : Colors.blue;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: color, width: 3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['event']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log['detail']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  log['time']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
