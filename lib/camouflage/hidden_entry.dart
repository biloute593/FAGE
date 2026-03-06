import 'package:flutter/material.dart';

/// Hidden Entry
/// Point d'entrée caché dans l'UI (ex: triple tap sur le faux écran).
class HiddenEntry extends StatelessWidget {
  final Widget child;
  final VoidCallback onTrigger;

  const HiddenEntry({super.key, required this.child, required this.onTrigger});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        // En vrai: une logique de Timer combinée à des touches rapides, 
        // ou un triple tap custom géré avec un listener de pointeur.
        onTrigger();
      },
      child: child, // Afficher l'interface "Camouflée" (ex: fausse calculatrice)
    );
  }
}
