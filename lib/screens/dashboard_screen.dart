import 'package:flutter/material.dart';
import 'mock_gallery_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _lockPhone = false;
  bool _lockPhotos = false;
  bool _lockApps = false;

  @override
  Widget build(BuildContext context) {
    const Color beige = Color(0xFFE8E4C9);
    const Color nightBlue = Color(0xFF0B1021);
    const Color cardBlue = Color(0xFF131A2D);

    return Scaffold(
      backgroundColor: nightBlue,
      appBar: AppBar(
        title: const Text(
          'Security Dashboard',
          style: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 1.2),
        ),
        backgroundColor: nightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: beige),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Protection Status / État de la protection',
                style: TextStyle(
                  color: beige.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildToggleCard(
                title: 'Lock entire phone',
                subtitle: 'Verrouiller tout mon téléphone',
                icon: Icons.phonelink_lock,
                value: _lockPhone,
                onChanged: (val) => setState(() => _lockPhone = val),
              ),
              const SizedBox(height: 16),
              
              _buildToggleCard(
                title: 'Lock photos',
                subtitle: 'Verrouiller photos',
                icon: Icons.photo_library_outlined,
                value: _lockPhotos,
                onChanged: (val) => setState(() => _lockPhotos = val),
              ),
              const SizedBox(height: 16),
              
              _buildToggleCard(
                title: 'Lock applications',
                subtitle: 'Verrouiller applications',
                icon: Icons.apps_outlined,
                value: _lockApps,
                onChanged: (val) => setState(() => _lockApps = val),
              ),
              
              const SizedBox(height: 64),
              
              // Mock Gallery Demo Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MockGalleryScreen()),
                    );
                  },
                  icon: const Icon(Icons.image_search),
                  label: const Text(
                    'OPEN GALLERY DEMO\nOUVRIR DÉMO GALERIE',
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: cardBlue,
                    foregroundColor: beige,
                    side: const BorderSide(color: beige, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    const Color beige = Color(0xFFE8E4C9);
    const Color cardBlue = Color(0xFF131A2D);

    return Container(
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: beige, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: beige,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: beige.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0B1021),
            activeTrackColor: beige,
            inactiveThumbColor: beige.withOpacity(0.5),
            inactiveTrackColor: Colors.black26,
          ),
        ],
      ),
    );
  }
}
