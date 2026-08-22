import 'package:flutter/material.dart';
import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/diagram_connector.dart';

class DiagramPainter extends CustomPainter {
  /// Constructeur.
  ///
  /// "required" oblige l'appelant à fournir un offset.
   DiagramPainter({
    required this.offset,
    required this.scale,
    required this.shapes,
    required this.connectors,
    required this.selectedShape,
  });

  /// Décalage du canevas reçu depuis GridCanvas.
  final Offset offset;

  // Niveau de zoom actuel transmis par GridCanvas.
  final double scale;

  /// Formes du diagramme à dessiner.
  final List<DiagramShape> shapes;

  final List<DiagramConnector> connectors;
  
  /// Forme actuellement sélectionnée.
  ///
  /// null = aucune sélection.
  final DiagramShape? selectedShape;
  /// Taille d'une case de la grille.
  ///
  /// Pour l'instant :
  /// 40 unités logiques Flutter.
  ///
  /// Ce n'est PAS encore un centimètre réel.
  static const double gridSize = 40.0;

  /// Recherche une forme à partir de son identifiant.
  ///
  /// Un connecteur ne possède que les IDs de ses extrémités.
  /// Il faut donc pouvoir retrouver les objets correspondants.
  DiagramShape? _shapeById(String id) {
    for (final shape in shapes) {
      if (shape.id == id) {
        return shape;
      }
    }

    // Aucun objet avec cet ID.
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// Objet décrivant COMMENT dessiner.
    ///
    /// On peut y définir :
    /// couleur, épaisseur, style, etc.
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    /// Ici il y a une petite astuce importante.
    ///
    /// On ne dessine PAS une grille gigantesque.
    /// On dessine uniquement ce qui est visible à l'écran.
    ///
    /// Le modulo (%) donne la position de la première ligne visible.
    ///
    /// Exemple avec gridSize = 40 :
    ///
    /// offset.dx = 53
    ///
    /// 53 % 40 = 13
    ///
    /// donc la première ligne verticale visible sera à x = 13.
    ///
    /// Puis :
    /// 13
    /// 53
    /// 93
    /// 133
    /// etc.
    ///
    /// C'est ce qui donne l'impression
    /// que la grille est infinie.
    // Taille APPARENTE d'une case à l'écran.
    //
    // Dans le monde, une case fait toujours 40 unités.
    //
    // À  50 % -> 20 pixels à l'écran
    // À 100 % -> 40 pixels
    // À 200 % -> 80 pixels
    final double scaledGridSize = gridSize * scale;
    
    // On cherche où doit commencer la première ligne visible,
    // mais cette fois avec la taille tenant compte du zoom.
    final double startX = offset.dx % scaledGridSize;
    final double startY = offset.dy % scaledGridSize;
    /// Dessine les lignes verticales.
    ///
    /// On part de startX et on avance d'une case à chaque fois.
    for (double x = startX; x <= size.width; x += scaledGridSize) {
      canvas.drawLine(
        /// Point de départ : haut de la fenêtre.
        Offset(x, 0),

        /// Point d'arrivée : bas de la fenêtre.
        Offset(x, size.height),

        paint,
      );
    }

    /// Dessine les lignes horizontales.
    for (double y = startY; y <= size.height; y += scaledGridSize) {
      canvas.drawLine(
        /// Départ : bord gauche.
        Offset(0, y),

        /// Arrivée : bord droit.
        Offset(size.width, y),

        paint,
      );
    }
    // ------------------------------------------------------------------
    // Dessin de l'origine du "monde"
    // ------------------------------------------------------------------
    //
    // Notre monde possède un point fixe (0, 0).
    //
    // Au démarrage :
    //   offset = (0, 0)
    // donc l'origine se trouve en haut à gauche.
    //
    // Si on déplace le canevas de :
    //   offset = (200, 100)
    //
    // alors le point (0, 0) du monde apparaît à l'écran en :
    //   x = 200
    //   y = 100
    //
    // Pour le moment, la conversion monde -> écran est donc simplement :
    //
    //   positionEcran = positionMonde + offset
    //
    // Plus tard, avec le zoom, cette formule évoluera.

    final originPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    // Position de l'origine dans les coordonnées de l'écran.
    final Offset origin = offset;

    // Petite croix horizontale.
    canvas.drawLine(
      Offset(origin.dx - 10, origin.dy),
      Offset(origin.dx + 10, origin.dy),
      originPaint,
    );

    // Petite croix verticale.
    canvas.drawLine(
      Offset(origin.dx, origin.dy - 10),
      Offset(origin.dx, origin.dy + 10),
      originPaint,
    );

    // ------------------------------------------------------------------
    // Dessin des connecteurs
    // ------------------------------------------------------------------
    //
    // IMPORTANT : nous dessinons les connecteurs AVANT les formes.
    //
    // Ainsi :
    //
    //      rectangle ───────── cercle
    //
    // la ligne passe visuellement "derrière" les formes.
    //
    // Pour cette première version, on relie simplement
    // le CENTRE des deux formes.
    for (final connector in connectors) {
      // Le connecteur connaît seulement les IDs.
      // On retrouve donc les deux formes.
      final DiagramShape? fromShape =
          _shapeById(connector.fromShapeId);

      final DiagramShape? toShape =
          _shapeById(connector.toShapeId);

      // Un connecteur invalide ne doit jamais faire planter
      // tout le rendu.
      //
      // Si une des formes n'existe plus, on ignore simplement
      // ce connecteur.
      if (fromShape == null || toShape == null) {
        continue;
      }

      // Centre de la première forme EN COORDONNÉES MONDE.
      final Offset fromCenter = Offset(
        fromShape.position.dx + fromShape.width / 2,
        fromShape.position.dy + fromShape.height / 2,
      );

      // Centre de la seconde.
      final Offset toCenter = Offset(
        toShape.position.dx + toShape.width / 2,
        toShape.position.dy + toShape.height / 2,
      );

      // Conversion monde -> écran.
      final Offset fromScreen =
          fromCenter * scale + offset;

      final Offset toScreen =
          toCenter * scale + offset;

      final connectorPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0;

      canvas.drawLine(
        fromScreen,
        toScreen,
        connectorPaint,
      );
    }

    // ------------------------------------------------------------------
    // Dessin des formes du diagramme
    // ------------------------------------------------------------------
    //
    // Chaque forme utilise des coordonnées DU MONDE.
    //
    // Pour la dessiner, nous devons donc convertir sa position
    // vers les coordonnées de l'écran.
    //
    // Notre formule est toujours :
    //
    //   écran = monde * scale + offset
    //
    // Même principe pour les dimensions :
    //
    //   taille écran = taille monde * scale
    //
    
    for (final shape in shapes) {
      // Conversion de la position monde -> écran.
      final Offset screenPosition =
          shape.position * scale + offset;

      // Conversion des dimensions monde -> écran.
      final double screenWidth = shape.width * scale;
      final double screenHeight = shape.height * scale;

      // Rect.fromLTWH signifie :
      //
      // Left
      // Top
      // Width
      // Height
      //
      // Donc :
      // - position X
      // - position Y
      // - largeur
      // - hauteur
      final Rect rect = Rect.fromLTWH(
        screenPosition.dx,
        screenPosition.dy,
        screenWidth,
        screenHeight,
      );

      // Pour l'instant, notre rectangle est simplement :
      //
      // - fond blanc ;
      // - contour noir ;
      // - épaisseur 2 pixels.
      //
      // On dessine d'abord le fond...
      final fillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      // ...puis le contour par-dessus.
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

    // --------------------------------------------------------------
    // Dessin selon le type de forme
    // --------------------------------------------------------------

    switch (shape.type) {
      case ShapeType.rectangle:
        // Pour un rectangle, notre "rect" est directement
        // la géométrie à dessiner.
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);

      case ShapeType.circle:
        // Pour un cercle, nous utilisons le même Rect comme
        // boîte englobante.
        //
        // drawOval() dessine une ellipse qui remplit exactement
        // cette boîte.
        //
        // Si width == height, nous obtenons donc un vrai cercle.
        canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, borderPaint);
    }

    // --------------------------------------------------------------
    // Indication visuelle de sélection
    // --------------------------------------------------------------
    //
    // On compare les identifiants plutôt que les objets eux-mêmes.
    //
    // Si cette forme est celle actuellement sélectionnée,
    // on dessine un deuxième contour autour d'elle.
    if (selectedShape?.id == shape.id) {
      final selectionPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
    
      // inflate(4) crée un rectangle légèrement plus grand :
      //
      // rectangle normal :
      // ┌─────────────┐
      // │             │
      // └─────────────┘
      //
      // sélection :
      // ┌ - - - - - - - ┐
      //   ┌─────────────┐
      //   │             │
      //   └─────────────┘
      // └ - - - - - - - ┘
      //
      // Ici on laisse 4 pixels autour de la forme.
      final Rect selectionRect = rect.inflate(4);
    
      canvas.drawRect(
        selectionRect,
        selectionPaint,
      );
    }
    }
  }

  /// Flutter demande ici :
  ///
  /// "Dois-je repeindre le CustomPainter ?"
  ///
  /// Si l'offset a changé, oui.
  ///
  /// Si rien n'a changé, inutile de redessiner.
  @override
  bool shouldRepaint(covariant DiagramPainter oldDelegate) {
    // Pour le moment, on redessine à chaque reconstruction.
    //
    // C'est volontairement simple pendant le prototype :
    // nos formes sont mutables, donc leur position peut changer
    // sans que la référence de la liste "shapes" change.
    //
    // On optimisera plus tard si nécessaire.
    return true;
  }
}
