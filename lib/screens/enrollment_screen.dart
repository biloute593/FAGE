import 'package:flutter/material.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  int _step = 0;
  bool _processing = false;
  final List<bool> _stepsCompleted = [false, false, false, false];

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Scan du visage',
      'description': 'Regardez droit vers la caméra.\nAjustez jusqu\'à voir votre visage centré.\nRestez immobile 3 secondes.',
      'icon': Icons.face_retouching_natural,
      'color': const Color(0xFF6C63FF),
    },
    {
      'title': 'Choix du geste',
      'description': 'Choisissez votre geste secret.\nIl doit être naturel mais unique.\nÉvitez les gestes trop communs.',
      'icon': Icons.pan_tool,
      'color': const Color(0xFF03DAC6),
    },
    {
      'title': 'Geste principal',
      'description': 'Effectuez votre geste choisi.\nRestez devant la caméra.\nLe geste sera enregistré 3 fois.',
      'icon': Icons.gesture,
      'color': Colors.amber,
    },
    {
      'title': 'Geste de panique',
      'description': 'Définissez un geste légèrement différent.\nCe geste déclenchera le mode sécurité.\nEx: même geste avec doigts plus écartés.',
      'icon': Icons.warning_amber,
      'color': Colors.orange,
    },
  ];

  Future<void> _processStep() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      _stepsCompleted[_step] = true;
      _processing = false;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      // Enrollment complete
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  'Inscription réussie',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: const Text(
              'Vos données biométriques ont été chiffrées et sauvegardées de manière sécurisée.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back
                },
                child: const Text('Terminer'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription biométrique'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress bar
              Row(
                children: List.generate(_steps.length, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? (step['color'] as Color)
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Étape ${_step + 1}/${_steps.length}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
              const SizedBox(height: 40),

              // Central icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (step['color'] as Color).withOpacity(0.15),
                  border: Border.all(
                    color: (step['color'] as Color).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (step['color'] as Color).withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _processing
                    ? CircularProgressIndicator(
                        color: step['color'] as Color,
                        strokeWidth: 3,
                      )
                    : Icon(
                        _stepsCompleted[_step]
                            ? Icons.check_circle
                            : step['icon'] as IconData,
                        size: 80,
                        color: _stepsCompleted[_step]
                            ? Colors.green
                            : step['color'] as Color,
                      ),
              ),
              const SizedBox(height: 40),

              // Step info
              Text(
                step['title'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                step['description'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.6,
                ),
              ),
              const Spacer(),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _processing ? null : _processStep,
                  icon: Icon(
                    _processing ? Icons.hourglass_empty : Icons.play_arrow,
                  ),
                  label: Text(
                    _processing
                        ? 'Enregistrement...'
                        : _stepsCompleted[_step]
                            ? 'Continuer'
                            : 'Démarrer',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: step['color'] as Color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
