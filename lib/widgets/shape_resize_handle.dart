import 'package:flutter/material.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/canvas_viewport.dart';

/// Poignée de redimensionnement affichée au coin bas-droit de la forme
/// sélectionnée.
///
/// Ce widget est PUREMENT visuel : il ne capture aucun geste lui-même
/// (pas de GestureDetector/Listener). Le drag est géré par le
/// GestureDetector unique de GridCanvas, qui utilise [screenCenter]
/// pour savoir si un geste démarre sur la poignée — même principe que
/// [ShapeHitTester] pour les formes, en évitant tout conflit
/// d'arène de gestes entre deux GestureDetector imbriqués.
///
/// Le [MouseRegion] adapte simplement le curseur au survol ; il ne
/// bloque pas les événements de pointeur, qui continuent jusqu'au
/// GestureDetector sous-jacent.
class ShapeResizeHandle extends StatelessWidget {
  const ShapeResizeHandle({super.key, required this.shape, required this.viewport});

  /// Forme actuellement sélectionnée, dont on affiche la poignée.
  final DiagramShape shape;

  /// Pan/zoom actuel du canevas, pour convertir [shape] en coordonnées
  /// écran.
  final CanvasViewport viewport;

  /// Diamètre du disque affiché.
  static const double size = 14.0;

  /// Centre de la poignée, en coordonnées ÉCRAN — coin bas-droit de la
  /// boîte englobante de [shape] (position + largeur/hauteur), converti
  /// via [viewport].
  ///
  /// Utilisé à la fois pour le rendu (ici) et pour le hit-testing du
  /// début de drag (GridCanvas._isOverResizeHandle).
  static Offset screenCenter(DiagramShape shape, CanvasViewport viewport) {
    return Offset(
      (shape.position.dx + shape.width) * viewport.scale + viewport.offset.dx,
      (shape.position.dy + shape.height) * viewport.scale + viewport.offset.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Offset center = screenCenter(shape, viewport);

    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpLeftDownRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }
}
