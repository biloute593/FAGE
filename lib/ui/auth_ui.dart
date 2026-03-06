import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/event_bus.dart';
import 'package:provider/provider.dart';

/// Silent Authentication UX
/// La caméra attend discrètement. Aucune interface n'est visible.
class SilentAuthUI extends StatefulWidget {
  const SilentAuthUI({super.key});

  @override
  State<SilentAuthUI> createState() => _SilentAuthUIState();
}

class _SilentAuthUIState extends State<SilentAuthUI> {
  late EventBus _eventBus;

  @override
  void initState() {
    super.initState();
    _eventBus = Provider.of<EventBus>(context, listen: false);

    // Écoute des échecs pour la vibration haptique (Micro-notif sans UI)
    _eventBus.onEvent(AppEvent.authFailure).listen((event) {
      HapticFeedback.heavyImpact(); // Vibration haptique forte
    });
    
    // Succès = Accès accordé silencieusement, transition au vault
    _eventBus.onEvent(AppEvent.authSuccess).listen((event) {
      HapticFeedback.lightImpact(); // Succès discret
      _navigateToVault();
    });
  }

  void _navigateToVault() {
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VaultUI()));
  }

  @override
  Widget build(BuildContext context) {
    // Interface totalement vide et noire (Camouflage / Discrétion)
    return const Scaffold(
      backgroundColor: Colors.black, // Le flux de la caméra n'est pas affiché, traité en arrière-plan
      body: SizedBox.expand(),
    );
  }
}
