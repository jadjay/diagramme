import 'package:flutter/material.dart';

/// Représente une forme présente dans notre diagramme.
///
/// Pour l'instant notre application ne connaît qu'un seul type
/// de forme : le rectangle.
///
/// Plus tard, cette classe pourra évoluer pour représenter :
/// - rectangles
/// - cercles
/// - etc.
///
/// IMPORTANT :
///
/// Les coordonnées stockées ici sont des coordonnées DU MONDE,
/// et non des coordonnées de l'écran.
///
/// Cela signifie que si un rectangle est en :
///
///   position = Offset(100, 50)
///
/// il reste TOUJOURS à (100, 50) dans notre diagramme,
/// même lorsque l'utilisateur déplace ou zoome le canevas.
///
/// C'est seulement au moment du dessin que nous convertirons :
///
///   coordonnées monde
///          ↓
///   coordonnées écran
///
class DiagramShape {
  DiagramShape({
    required this.id,
    required this.position,
    required this.width,
    required this.height,
  });

  /// Identifiant unique de la forme.
  ///
  /// Il deviendra important pour :
  /// - sélectionner une forme ;
  /// - connecter deux formes ;
  /// - sauvegarder le diagramme.
  final String id;

  /// Position de la forme DANS LE MONDE.
  ///
  /// Pour un rectangle, on considère que cette position
  /// correspond à son coin supérieur gauche.
  Offset position;

  /// Largeur dans les unités du monde.
  double width;

  /// Hauteur dans les unités du monde.
  double height;
}