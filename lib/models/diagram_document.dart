import 'package:flutter/material.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/diagram_connector.dart';

/// État du document : les formes, les connecteurs, et la sélection.
///
/// Cette classe ne connaît ni les coordonnées écran, ni le hit-testing,
/// ni le rendu : elle représente uniquement le contenu du diagramme et
/// les règles qui le font évoluer (créer une forme, créer un
/// connecteur, supprimer la sélection...).
///
/// GridCanvas reste responsable de traduire les gestes utilisateur
/// (position écran, outil actif, forme sous le clic) en appels à ces
/// méthodes.
class DiagramDocument {
  /// Toutes les formes du diagramme.
  final List<DiagramShape> shapes = [];

  /// Tous les connecteurs du diagramme.
  final List<DiagramConnector> connectors = [];

  int _nextShapeId = 1;

  /// Forme actuellement sélectionnée.
  ///
  /// null signifie qu'aucune forme n'est sélectionnée.
  DiagramShape? selectedShape;

  /// Forme actuellement en cours d'édition de texte.
  ///
  /// null = aucune édition en cours.
  DiagramShape? editingShape;

  /// Première forme choisie lors de la création d'un connecteur.
  ///
  /// null = aucune première extrémité mémorisée.
  ///
  /// Workflow :
  /// 1. outil connecteur actif ;
  /// 2. clic sur forme A -> connectorStartShape = A ;
  /// 3. clic sur forme B -> création du connecteur ;
  /// 4. connectorStartShape redevient null.
  DiagramShape? connectorStartShape;

  /// Forme actuellement en cours de déplacement (drag).
  ///
  /// Attention à la différence avec [selectedShape] :
  /// selectedShape = "cette forme est sélectionnée" ;
  /// draggedShape  = "je suis EN TRAIN de déplacer cette forme".
  DiagramShape? draggedShape;

  /// Forme actuellement en cours de redimensionnement (drag de sa
  /// poignée). Mutuellement exclusif avec [draggedShape] : un geste
  /// donné redimensionne OU déplace, jamais les deux.
  DiagramShape? resizingShape;

  /// Ajoute un rectangle à [worldPosition] (coordonnées du monde) et le
  /// retourne.
  DiagramShape addRectangle(Offset worldPosition) {
    final shape = DiagramShape(
      id: 'shape-${_nextShapeId++}',
      type: ShapeType.rectangle,
      position: worldPosition,
      width: 200,
      height: 100,
    );

    shapes.add(shape);

    return shape;
  }

  /// Ajoute un cercle à [worldPosition] (coordonnées du monde) et le
  /// retourne.
  ///
  /// Un cercle est représenté par une boîte englobante carrée de
  /// 120 × 120 unités (width == height).
  DiagramShape addCircle(Offset worldPosition) {
    final shape = DiagramShape(
      id: 'shape-${_nextShapeId++}',
      type: ShapeType.circle,
      position: worldPosition,
      width: 120,
      height: 120,
    );

    shapes.add(shape);

    return shape;
  }

  /// Fait progresser la création d'un connecteur vers [shape].
  ///
  /// Premier appel : mémorise [shape] comme point de départ et la
  /// sélectionne.
  ///
  /// Second appel, sur une autre forme : crée le connecteur entre les
  /// deux formes, la sélectionne, et termine le workflow. Relier une
  /// forme à elle-même est ignoré.
  void handleConnectorTarget(DiagramShape shape) {
    if (connectorStartShape == null) {
      connectorStartShape = shape;
      selectedShape = shape;

      return;
    }

    // Pour l'instant, on interdit de relier une forme à elle-même.
    if (connectorStartShape!.id == shape.id) {
      return;
    }

    connectors.add(
      DiagramConnector(
        id: 'connector-${connectors.length + 1}',
        fromShapeId: connectorStartShape!.id,
        toShapeId: shape.id,
      ),
    );

    // Le connecteur est terminé.
    connectorStartShape = null;

    // La deuxième forme devient la sélection courante.
    selectedShape = shape;
  }

  /// Supprime la forme actuellement sélectionnée.
  ///
  /// Cette suppression nettoie aussi :
  /// - les connecteurs qui référencent cette forme ;
  /// - editingShape / connectorStartShape / draggedShape / resizingShape
  ///   s'ils pointaient vers la forme supprimée.
  ///
  /// Si aucune forme n'est sélectionnée, ne fait rien.
  void deleteSelectedShape() {
    final DiagramShape? shape = selectedShape;

    if (shape == null) {
      return;
    }

    // Un connecteur doit disparaître si la forme supprimée est
    // son point de départ ou son point d'arrivée.
    connectors.removeWhere(
      (connector) =>
          connector.fromShapeId == shape.id || connector.toShapeId == shape.id,
    );

    shapes.removeWhere((candidate) => candidate.id == shape.id);

    selectedShape = null;

    if (editingShape?.id == shape.id) {
      editingShape = null;
    }

    if (connectorStartShape?.id == shape.id) {
      connectorStartShape = null;
    }

    if (draggedShape?.id == shape.id) {
      draggedShape = null;
    }

    if (resizingShape?.id == shape.id) {
      resizingShape = null;
    }
  }

  /// Remplace tout le contenu du document par [loadedShapes] et
  /// [loadedConnectors] — typiquement après le chargement d'un fichier
  /// (voir `lib/persistence/diagram_file_format.dart`) — et réinitialise
  /// toute sélection/édition/drag en cours, qui ne peut plus référencer
  /// une forme valide.
  ///
  /// Recalcule aussi [_nextShapeId] à partir des identifiants déjà
  /// présents dans [loadedShapes], pour que les prochaines formes créées
  /// par [addRectangle]/[addCircle] ne réutilisent jamais un identifiant
  /// déjà chargé depuis le fichier.
  void replaceContent(
    List<DiagramShape> loadedShapes,
    List<DiagramConnector> loadedConnectors,
  ) {
    shapes
      ..clear()
      ..addAll(loadedShapes);

    connectors
      ..clear()
      ..addAll(loadedConnectors);

    selectedShape = null;
    editingShape = null;
    connectorStartShape = null;
    draggedShape = null;
    resizingShape = null;

    _nextShapeId = _highestLoadedShapeId(loadedShapes) + 1;
  }

  /// Identifiants générés sous la forme `shape-N` (voir [addRectangle] et
  /// [addCircle]) : on en extrait le plus grand N déjà utilisé, pour
  /// reprendre la numérotation juste après.
  ///
  /// Un identifiant qui ne suit pas ce format (chargé depuis un fichier
  /// édité à la main, par exemple) est simplement ignoré ici : il reste
  /// parfaitement valide comme identifiant, seule la numérotation
  /// automatique des PROCHAINES formes s'appuie sur ce format.
  static int _highestLoadedShapeId(List<DiagramShape> shapes) {
    final RegExp pattern = RegExp(r'^shape-(\d+)$');

    int highest = 0;

    for (final DiagramShape shape in shapes) {
      final RegExpMatch? match = pattern.firstMatch(shape.id);

      if (match == null) {
        continue;
      }

      final int value = int.parse(match.group(1)!);

      if (value > highest) {
        highest = value;
      }
    }

    return highest;
  }
}
