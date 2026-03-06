import 'package:flutter/material.dart';
import '../core/event_bus.dart';

/// Fake Environment (Panic)
/// Environnement leurre affiché lorsque le Panic Mode est activé.
class FakeEnvironmentManager {
  final EventBus eventBus;

  FakeEnvironmentManager({required this.eventBus}) {
    // Si Panic Triggered -> on déverrouille visuellement de façon normale,
    // mais on injecte le Fake Environment
    eventBus.onEvent(AppEvent.panicTriggered).listen((_) {
      _deployFakeEnvironment();
    });
  }

  void _deployFakeEnvironment() {
    // 1. Creation log secret horodaté
    _createSilentAuditLog();

    // 2. Alerte SMS optionnelle
    _sendSilentSos();

    // 3. (UI Side) Afficher la fausse galerie au lieu du Vault
    // Cela est intercepté par le Navigator globalement.
  }

  void _createSilentAuditLog() {
    debugPrint("[SECRET LOG] Panic mode triggered by user deviation gesture.");
  }
  
  void _sendSilentSos() {
    // Envoi d'un message API crypté/SMS au contact
  }
}

class FakeGalleryUI extends StatelessWidget {
  const FakeGalleryUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galerie')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: 15,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(2),
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      ),
    );
  }
}
