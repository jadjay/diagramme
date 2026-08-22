/// Représente une connexion entre deux formes du diagramme.
///
/// Un connecteur ne stocke PAS ses coordonnées graphiques.
///
/// Il stocke uniquement l'identifiant de sa forme de départ
/// et celui de sa forme d'arrivée.
///
/// Exemple :
///
///   rectangle-1 ─────────── circle-2
///
/// devient :
///
///   fromShapeId = "rectangle-1"
///   toShapeId   = "circle-2"
///
/// Les coordonnées réelles de la ligne seront calculées
/// au moment du dessin à partir de la position des deux formes.
///
/// Conséquence importante :
///
/// si rectangle-1 est déplacé, aucune modification du connecteur
/// n'est nécessaire. Lors du prochain dessin, la ligne utilisera
/// automatiquement la nouvelle position du rectangle.
class DiagramConnector {
  DiagramConnector({
    required this.id,
    required this.fromShapeId,
    required this.toShapeId,
  });

  /// Identifiant unique du connecteur.
  final String id;

  /// Identifiant de la forme de départ.
  final String fromShapeId;

  /// Identifiant de la forme d'arrivée.
  final String toShapeId;
}