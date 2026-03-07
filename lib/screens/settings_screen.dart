import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'enrollment_screen.dart';
import 'panic_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _continuousAuth = true;
  bool _hapticFeedback = true;
  bool _rppgLiveness = false;
  bool _camouflage = false;
  bool _antiSpoofing = true;
  String _lockoutLevel = 'Modéré';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Réglages',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Configuration de GestureFace',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 28),

            _SectionHeader(title: 'Sécurité', icon: Icons.security),
            _SettingsTile(
              title: 'Auth. continue',
              subtitle: 'Vérifier en arrière-plan',
              value: _continuousAuth,
              onChanged: (v) => setState(() => _continuousAuth = v),
            ),
            _SettingsTile(
              title: 'Anti-falsification (rPPG)',
              subtitle: 'Détection de présence réelle',
              value: _rppgLiveness,
              onChanged: (v) => setState(() => _rppgLiveness = v),
            ),
            _SettingsTile(
              title: 'Anti-spoofing',
              subtitle: 'Bloquer photos et masques',
              value: _antiSpoofing,
              onChanged: (v) => setState(() => _antiSpoofing = v),
            ),
            const SizedBox(height: 8),

            // Lockout level selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_off, color: Colors.white60, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Niveau de verrouillage',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Délai après échecs répétés',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: _lockoutLevel,
                    dropdownColor: const Color(0xFF2A2A3E),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    items: ['Faible', 'Modéré', 'Strict']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _lockoutLevel = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionHeader(title: 'Interface', icon: Icons.palette),
            _SettingsTile(
              title: 'Retour haptique',
              subtitle: 'Vibration lors des événements',
              value: _hapticFeedback,
              onChanged: (v) => setState(() => _hapticFeedback = v),
            ),
            _SettingsTile(
              title: 'Mode camouflage',
              subtitle: 'Icône et nom d\'app discrets',
              value: _camouflage,
              onChanged: (v) {
                setState(() => _camouflage = v);
                if (v) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'L\'icône sera changée au prochain redémarrage'),
                      backgroundColor: const Color(0xFF2A2A3E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            _SectionHeader(title: 'Actions', icon: Icons.build),
            _ActionTile(
              icon: Icons.person_add,
              title: 'Réinscrire la biométrie',
              subtitle: 'Mettre à jour visage et geste',
              color: const Color(0xFF6C63FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EnrollmentScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.warning_amber,
              title: 'Configurer mode Panic',
              subtitle: 'Geste de détresse et contacts',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PanicScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.logout,
              title: 'Se déconnecter',
              subtitle: 'Retour à l\'authentification',
              color: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E2E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Se déconnecter ?',
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Vous serez redirigé vers l\'écran d\'authentification.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler',
                            style: TextStyle(color: Colors.white60)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const AuthScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Déconnecter'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Version
            Center(
              child: Text(
                'GestureFace v3.1.0 • Build 1',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
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
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}


