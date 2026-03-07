import 'package:flutter/material.dart';

class PanicScreen extends StatefulWidget {
  const PanicScreen({super.key});

  @override
  State<PanicScreen> createState() => _PanicScreenState();
}

class _PanicScreenState extends State<PanicScreen> {
  bool _panicEnabled = true;
  bool _smsAlert = false;
  bool _fakeGallery = true;
  bool _silentLog = true;
  String _contactNumber = '';
  int _deviationDegrees = 5;

  final TextEditingController _contactCtrl = TextEditingController();

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Panic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Configuration sauvegardée ✓'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Le mode Panic est activé par un geste subtilement différent de votre geste normal, en situation de contrainte.',
                      style: TextStyle(color: Colors.orange, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Master toggle
            _PanicTile(
              icon: Icons.emergency,
              title: 'Mode Panic activé',
              subtitle: 'Activer la détection de geste de détresse',
              value: _panicEnabled,
              onChanged: (v) => setState(() => _panicEnabled = v),
              color: Colors.orange,
            ),
            const SizedBox(height: 20),

            // Deviation slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Colors.white60, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Déviation du geste',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+$_deviationDegrees°',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _deviationDegrees.toDouble(),
                    min: 3,
                    max: 15,
                    divisions: 12,
                    activeColor: Colors.orange,
                    inactiveColor: Colors.white12,
                    onChanged: _panicEnabled
                        ? (v) => setState(() => _deviationDegrees = v.round())
                        : null,
                  ),
                  Text(
                    'Angle d\'écartement des doigts supplémentaire',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Actions on panic
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'ACTIONS EN CAS DE PANIQUE',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _PanicTile(
              icon: Icons.photo_library,
              title: 'Galerie leurre',
              subtitle: 'Afficher de fausses photos inoffensives',
              value: _fakeGallery,
              onChanged: _panicEnabled
                  ? (v) => setState(() => _fakeGallery = v)
                  : null,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            _PanicTile(
              icon: Icons.description,
              title: 'Journal secret',
              subtitle: 'Enregistrer silencieusement l\'événement',
              value: _silentLog,
              onChanged: _panicEnabled
                  ? (v) => setState(() => _silentLog = v)
                  : null,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            _PanicTile(
              icon: Icons.sms,
              title: 'Alerte SMS',
              subtitle: 'Envoyer un SMS à un contact de confiance',
              value: _smsAlert,
              onChanged: _panicEnabled
                  ? (v) => setState(() => _smsAlert = v)
                  : null,
              color: Colors.orange,
            ),
            if (_smsAlert) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '+33 6 12 34 56 78',
                  hintStyle: const TextStyle(color: Colors.white38),
                  labelText: 'Numéro du contact de confiance',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.phone, color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _contactNumber = v),
              ),
            ],
            const SizedBox(height: 28),

            // Test button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _panicEnabled
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E2E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Row(
                              children: [
                                Icon(Icons.play_arrow, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Test Mode Panic',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            content: const Text(
                              'Simulation du mode panic:\n✓ Galerie leurre affichée\n✓ Journal secret créé\n✓ SMS simulé (non envoyé en test)',
                              style: TextStyle(color: Colors.white70, height: 1.6),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Tester le mode Panic'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanicTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color color;

  const _PanicTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? color : Colors.white38, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: onChanged != null ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}
