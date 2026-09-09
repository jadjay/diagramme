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
///

/// Types de formes supportés par l'application.
///
/// Pour l'instant :
/// - rectangle
/// - circle
///
/// On pourra plus tard ajouter :
/// - diamond
/// - ellipse
/// - etc.
enum ShapeType { rectangle, circle }

/// Outils disponibles dans la barre d'outils.
///
/// select n'est pas encore utilisé explicitement :
/// pour l'instant "aucun outil actif" joue ce rôle.
///
/// Mais on prépare une structure propre pour la suite.
enum ToolType { select, rectangle, circle, connector }

class DiagramShape {
  DiagramShape({
    required this.id,
    required this.type,
    required this.position,
    required this.width,
    required this.height,
    this.text = '',
    this.fillColor = Colors.white,
    this.strokeColor = Colors.black,
  });

  /// Identifiant unique de la forme.
  ///
  /// Il deviendra important pour :
  /// - sélectionner une forme ;
  /// - connecter deux formes ;
  /// - sauvegarder le diagramme.
  final String id;

  /// Type géométrique de la forme.
  final ShapeType type;

  /// Position de la forme DANS LE MONDE.
  ///
  /// Pour un rectangle, on considère que cette position
  /// correspond à son coin supérieur gauche.
  Offset position;

  /// Largeur dans les unités du monde.
  double width;

  /// Hauteur dans les unités du monde.
  double height;

  /// Texte affiché à l'intérieur de la forme.
  ///
  /// Chaîne vide = aucun texte.
  String text;

  /// Couleur de remplissage de la forme.
  Color fillColor;

  /// Couleur du contour de la forme.
  Color strokeColor;

  /// Taille minimale (largeur et hauteur) autorisée pour une forme.
  ///
  /// Empêche [resizeBy] de produire des formes trop petites, ou des
  /// dimensions négatives ou nulles.
  static const double minSize = 20.0;

  /// Redimensionne la forme en appliquant [worldDelta] (coordonnées
  /// MONDE) à ses dimensions, en gardant [position] fixe — c'est-à-dire
  /// en tirant depuis le coin BAS-DROIT de sa boîte englobante.
  ///
  /// Pour un rectangle, largeur et hauteur évoluent indépendamment.
  ///
  /// Pour un cercle, width == height doit rester vrai pour que la forme
  /// reste un vrai cercle (voir DiagramPainter.drawOval et
  /// ShapeHitTester, qui supposent tous deux width == height) : on
  /// applique donc la moyenne des deux axes du delta aux deux
  /// dimensions à la fois.
  ///
  /// Dans tous les cas, [minSize] empêche la forme de devenir trop
  /// petite ou d'avoir des dimensions négatives.
  void resizeBy(Offset worldDelta) {
    switch (type) {
      case ShapeType.rectangle:
        width = (width + worldDelta.dx).clamp(minSize, double.infinity);
        height = (height + worldDelta.dy).clamp(minSize, double.infinity);

      case ShapeType.circle:
        final double delta = (worldDelta.dx + worldDelta.dy) / 2;
        final double newSize = (width + delta).clamp(minSize, double.infinity);

        width = newSize;
        height = newSize;
    }
  }
}
