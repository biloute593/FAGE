import 'package:flutter/material.dart';

/// UI Configuration du Panic Mode (Enregistrement de la déviation de geste)
class PanicSettingsUI extends StatelessWidget {
  const PanicSettingsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sécurité d\'urgence (Panic)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text("Configuration du geste d'urgence", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Le geste de panique remplace l'ouverture de votre coffre fort par un environnement factice en cas de menace physique. Il doit être subtilement différent de votre geste normal (ex: doigts plus écartés)."),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.fingerprint),
            title: Text("Enregistrer geste Panic"),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            leading: Icon(Icons.contact_phone),
            title: Text("Contact de confiance (Alerte SMS)"),
            trailing: Icon(Icons.arrow_forward_ios),
          )
        ],
      ),
    );
  }
}
