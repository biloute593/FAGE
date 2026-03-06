import 'package:flutter/material.dart';

class DashboardUI extends StatelessWidget {
  const DashboardUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GestureFace Vault')),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.photo_library), title: Text('Photos Privées')),
          ListTile(leading: Icon(Icons.note), title: Text('Notes Secrètes')),
          ListTile(leading: Icon(Icons.apps), title: Text('Applications Cachées')),
          Divider(),
          ListTile(leading: Icon(Icons.settings), title: Text('Paramètres et Camouflage')),
        ],
      ),
    );
  }
}

class EnrollmentUI extends StatelessWidget {
  const EnrollmentUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription Biométrique')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Étape 1: Scan Visage (5 angles)"),
            Text("Étape 2: Choix du Geste"),
            Text("Étape 3: Main Dominante"),
            Text("Étape 4: Geste Panic"),
          ],
        ),
      ),
    );
  }
}
