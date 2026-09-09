import 'package:flutter/material.dart';

import 'package:diagramme/models/diagram_shape.dart';

/// Détermine quelle forme se trouve sous un point donné.
///
/// Cette classe ne connaît que les coordonnées DU MONDE : la
/// conversion écran -> monde (voir [CanvasTransform]) reste à la
/// charge de l'appelant.
///
/// Elle ne connaît pas non plus la notion de sélection : elle répond
/// uniquement à la question "quelle forme est ici ?", sans modifier
/// aucun état. C'est à l'appelant (GridCanvas) de décider quoi faire
/// du résultat (sélectionner, démarrer un drag, démarrer un
/// connecteur...).
class ShapeHitTester {
  const ShapeHitTester(this.shapes);

  /// Formes testées, dans leur ordre de dessin (la première de la
  /// liste est dessinée en dessous des suivantes).
  final List<DiagramShape> shapes;

  /// Recherche la forme située à [worldPosition].
  ///
  /// On parcourt les formes à l'envers : si deux formes se
  /// superposent, la dernière dessinée est visuellement au-dessus des
  /// autres, donc c'est elle que le clic doit sélectionner.
  ///
  /// Retourne `null` si aucune forme ne contient ce point.
  DiagramShape? shapeAt(Offset worldPosition) {
    for (final shape in shapes.reversed) {
      if (_contains(shape, worldPosition)) {
        return shape;
      }
    }

    return null;
  }

  /// "Hit-testing" = déterminer si [worldPosition] se trouve
  /// réellement à l'intérieur de [shape].
  bool _contains(DiagramShape shape, Offset worldPosition) {
    switch (shape.type) {
      case ShapeType.rectangle:
        // Pour un rectangle, Flutter sait déjà répondre
        // directement à la question grâce à Rect.contains().
        final Rect bounds = Rect.fromLTWH(
          shape.position.dx,
          shape.position.dy,
          shape.width,
          shape.height,
        );

        return bounds.contains(worldPosition);

      case ShapeType.circle:
        // Notre cercle est défini par une boîte :
        //
        // position ----+
        //     ↓        |
        //     ┌─────────────┐
        //     │    *****    │
        //     │  **     **  │
        //     │ *    •    * │
        //     │  **     **  │
        //     │    *****    │
        //     └─────────────┘
        //
        //                  • = centre
        //
        // Comme width == height pour nos cercles,
        // le rayon vaut simplement width / 2.
        final double radius = shape.width / 2;

        final Offset center = Offset(
          shape.position.dx + radius,
          shape.position.dy + radius,
        );

        // Distance entre le point testé et le centre :
        // distance <= rayon => le point est dans le cercle.
        final double distanceFromCenter = (worldPosition - center).distance;

        return distanceFromCenter <= radius;
    }
  }
}
