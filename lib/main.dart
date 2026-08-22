import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:diagramme/models/diagram_shape.dart';
// import 'package:diagramme/models/diagram_connector.dart';
// import 'package:diagramme/painters/diagram_painter.dart';
// import 'package:diagramme/widgets/diagram_toolbar.dart';
// import 'package:diagramme/widgets/zoom_indicator.dart';
import 'package:diagramme/widgets/diagram_canvas.dart';
/// Point d'entrée de l'application.
///
/// C'est l'équivalent du :
///     if __name__ == "__main__":
/// en Python, conceptuellement.
void main() {
  runApp(const DiagrammeApp());
}

/// Widget racine de l'application.
///
/// StatelessWidget = widget sans état interne mutable.
/// Ici, l'application elle-même ne stocke rien :
/// elle se contente d'afficher notre écran principal.
class DiagrammeApp extends StatelessWidget {
  const DiagrammeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Supprime le petit bandeau "DEBUG" en haut à droite.
      debugShowCheckedModeBanner: false,

      // Scaffold fournit une structure de page Flutter classique.
      // Pour l'instant on n'utilise ni AppBar ni boutons :
      // juste notre zone de dessin.
      home: Scaffold(
        body: GridCanvas(),
      ),
    );
  }
}


