import 'package:flutter/material.dart';

/// Décrit la transformation entre les deux systèmes de coordonnées
/// utilisés par notre éditeur.
///
/// Nous avons deux "mondes" :
///
/// 1. Les coordonnées ÉCRAN
///    Ce sont les pixels dans la fenêtre Flutter.
///
/// 2. Les coordonnées MONDE
///    Ce sont les coordonnées permanentes de notre diagramme.
///
/// Le déplacement du canevas [offset] et son niveau de zoom [scale]
/// permettent de passer de l'un à l'autre.
class CanvasTransform {
  const CanvasTransform({
    required this.offset,
    required this.scale,
  });

  /// Décalage actuel du monde par rapport à l'écran.
  ///
  /// Il change lorsque l'utilisateur déplace le canevas.
  final Offset offset;

  /// Niveau de zoom actuel.
  ///
  /// 1.0 = 100 %
  /// 2.0 = 200 %
  /// 0.5 = 50 %
  final double scale;

  /// Convertit une position écran en position monde.
  ///
  /// C'est la formule que nous avions jusqu'ici directement
  /// dans diagram_canvas.dart :
  ///
  ///   monde = (écran - offset) / scale
  Offset screenToWorld(Offset screenPosition) {
    return (screenPosition - offset) / scale;
  }

  /// Convertit une position monde en position écran.
  ///
  /// C'est simplement l'opération inverse :
  ///
  ///   écran = monde * scale + offset
  Offset worldToScreen(Offset worldPosition) {
    return worldPosition * scale + offset;
  }
}