import 'package:flutter/material.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/canvas_viewport.dart';

/// Champ de texte superposé au-dessus de la forme en cours d'édition.
///
/// Ce widget ne gère aucun état lui-même : il se contente de
/// positionner un [TextField] à l'écran, à l'endroit où se trouve
/// [shape] compte tenu du pan/zoom actuel du canevas ([viewport]), et
/// de relayer les changements via [onChanged] / [onSubmitted].
class ShapeTextEditor extends StatelessWidget {
  const ShapeTextEditor({
    super.key,
    required this.shape,
    required this.viewport,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  /// Forme actuellement éditée. Sa position/taille (coordonnées MONDE)
  /// détermine où placer le champ à l'écran.
  final DiagramShape shape;

  /// Pan/zoom actuel du canevas, pour convertir [shape] en coordonnées
  /// écran : écran = monde * scale + offset.
  final CanvasViewport viewport;

  final TextEditingController controller;

  /// Appelé à chaque frappe : GridCanvas copie la valeur dans le
  /// modèle en temps réel, pour ne jamais perdre de texte.
  final ValueChanged<String> onChanged;

  /// Appelé à la validation (Entrée sur Linux, bouton "done" du
  /// clavier sur Android).
  final ValueChanged<String> onSubmitted;

  static const double _height = 48.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // shape.position est en coordonnées MONDE.
      //
      // écran = monde * scale + offset
      left: shape.position.dx * viewport.scale + viewport.offset.dx,

      // Centre verticalement le champ dans la forme.
      top:
          shape.position.dy * viewport.scale +
          viewport.offset.dy +
          (shape.height * viewport.scale - _height) / 2,

      // L'éditeur prend la largeur actuelle de la forme.
      width: shape.width * viewport.scale,
      height: _height,
      child: TextField(
        controller: controller,
        autofocus: true,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
