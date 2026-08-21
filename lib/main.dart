import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:diagramme/models/diagram_shape.dart';
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

/// Notre zone de dessin.
///
/// StatefulWidget = widget qui possède un état mutable.
///
/// Ici, l'état à mémoriser est la position de la grille.
/// Quand l'utilisateur déplace la souris, cette position change.
///
/// C'est précisément pour ça qu'on ne peut plus utiliser
/// un StatelessWidget comme avant.
class GridCanvas extends StatefulWidget {
  const GridCanvas({super.key});

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

/// État associé à GridCanvas.
///
/// La convention Flutter met souvent un "_" devant les classes privées.
/// "_GridCanvasState" n'est donc visible que dans ce fichier.
class _GridCanvasState extends State<GridCanvas> {
    /// Décalage actuel du canevas.
    ///
    /// Offset contient deux nombres :
    /// - dx : déplacement horizontal
    /// - dy : déplacement vertical
    ///
    /// Offset.zero signifie :
    /// dx = 0
    /// dy = 0
    Offset offset = Offset.zero;
    /// Facteur de zoom du canevas.
    ///
    /// 1.0 = 100 %
    /// 2.0 = 200 %
    /// 0.5 = 50 %
    double scale = 1.0;

    /// Le canevas démarre maintenant réellement vide.
    /// Les formes seront ajoutées par l'utilisateur.
    final List<DiagramShape> shapes = [];

    /// Forme actuellement sélectionnée.
    ///
    /// null signifie qu'aucune forme n'est sélectionnée.
    ///
    /// On stocke pour l'instant directement une référence vers
    /// l'objet DiagramShape concerné.
    ///
    /// Plus tard, on pourra éventuellement ne stocker que son ID.
    DiagramShape? selectedShape;

    /// Recherche la forme située sous un point de l'écran.
    ///
    /// [screenPosition] est une position provenant de la souris,
    /// donc exprimée dans les coordonnées DE L'ÉCRAN.
    ///
    /// Nos formes, elles, sont stockées dans les coordonnées DU MONDE.
    ///
    /// Première étape : convertir écran -> monde.
    ///
    /// Formule inverse de celle utilisée pour dessiner :
    ///
    ///   écran = monde * scale + offset
    ///
    /// donc :
    ///
    ///   monde = (écran - offset) / scale
    DiagramShape? _shapeAtScreenPosition(Offset screenPosition) {
      final Offset worldPosition =
          (screenPosition - offset) / scale;

      // On parcourt les formes à l'envers.
      //
      // Pourquoi ?
      //
      // Si un jour deux formes se superposent, la dernière dessinée
      // est visuellement au-dessus des autres.
      //
      // Il est donc logique que le clic sélectionne celle du dessus.
      for (final shape in shapes.reversed) {
        // On reconstruit le rectangle, mais cette fois
        // EN COORDONNÉES DU MONDE.
        final Rect bounds = Rect.fromLTWH(
          shape.position.dx,
          shape.position.dy,
          shape.width,
          shape.height,
        );

        // contains() répond simplement :
        //
        // "ce point est-il à l'intérieur du rectangle ?"
        if (bounds.contains(worldPosition)) {
          return shape;
        }
      }

      // Le clic était dans le vide.
      return null;
    }
    /// Forme actuellement en cours de déplacement.
    ///
    /// Attention à la différence avec selectedShape :
    ///
    /// selectedShape = "cette forme est sélectionnée"
    /// draggedShape  = "je suis EN TRAIN de déplacer cette forme"
    ///
    /// Si draggedShape == null pendant un drag,
    /// alors le drag sert à déplacer le canevas.
    DiagramShape? draggedShape;

    /// Outil actuellement sélectionné.
    ///
    /// Pour l'instant :
    /// - null = mode normal / sélection
    /// - 'rectangle' = le prochain clic crée un rectangle
    String? activeTool;
    
    void _handleMouseWheel(PointerScrollEvent event) {
      // Position actuelle de la souris dans la fenêtre.
      //
      // C'est autour de CE point que nous voulons zoomer.
      final Offset mousePosition = event.localPosition;

      // On choisit un facteur multiplicatif.
      //
      // Molette vers le haut  -> zoom avant  : × 1.1
      // Molette vers le bas   -> zoom arrière: ÷ 1.1
      //
      // Utiliser une multiplication plutôt qu'un "+ 0.1"
      // donne un zoom plus régulier.
      final double zoomFactor =
          event.scrollDelta.dy < 0 ? 1.1 : 1 / 1.1;

      // On calcule le nouveau niveau de zoom.
      //
      // clamp() impose des limites :
      //   0.1 = 10 %
      //   5.0 = 500 %
      //
      // Ça évite de pouvoir zoomer jusqu'à zéro ou l'infini.
      final double newScale =
          (scale * zoomFactor).clamp(0.1, 5.0);

      // ---------------------------------------------------------------
      // Partie importante : conserver le point sous la souris
      // ---------------------------------------------------------------
      //
      // Notre transformation monde -> écran sera :
      //
      //   écran = monde * scale + offset
      //
      // On cherche donc d'abord quelle coordonnée DU MONDE
      // se trouve actuellement sous la souris.
      //
      // En inversant la formule :
      //
      //   monde = (écran - offset) / scale
      //
      final Offset worldPointUnderMouse =
          (mousePosition - offset) / scale;

      // Maintenant nous changeons le zoom.
      //
      // Mais si on changeait seulement "scale", le point observé
      // se déplacerait à l'écran.
      //
      // On recalcule donc offset pour que :
      //
      //   mousePosition =
      //       worldPointUnderMouse * newScale + newOffset
      //
      // donc :
      //
      //   newOffset =
      //       mousePosition - worldPointUnderMouse * newScale
      final Offset newOffset =
          mousePosition - worldPointUnderMouse * newScale;

      setState(() {
        scale = newScale;
        offset = newOffset;
      });
    }
  @override
  Widget build(BuildContext context) {
    /// GestureDetector permet d'intercepter les gestes utilisateur :
    /// clic, glisser, double clic, etc.
    return Stack(
        children: [
            Listener(
      // Listener reçoit les événements "bas niveau" de la souris.
      //
      // Ici, on s'intéresse notamment à PointerScrollEvent,
      // c'est-à-dire la molette.
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleMouseWheel(event);
        }
      },

  // Notre GestureDetector reste présent à l'intérieur.
  //
  // Il continue de gérer le clic-glisser exactement comme avant.
  child: GestureDetector(
      /// "opaque" signifie que toute la surface du widget
      /// capture les interactions, même si elle est visuellement vide.
      behavior: HitTestBehavior.opaque,

    //onTapDown: (details) {
    //
    //  // details.localPosition = position du clic dans le widget,
    //  // donc dans les coordonnées de l'écran.
    //  final DiagramShape? shape =
    //      _shapeAtScreenPosition(details.localPosition);
    //
    //  setState(() {
    //    selectedShape = shape;
    //  });
    //
    //  if (shape != null) {
    //    debugPrint('Forme sélectionnée : ${shape.id}');
    //  } else {
    //    debugPrint('Aucune forme sélectionnée');
    //  }
    //},
    
    onTapDown: (details) {
      // ----------------------------------------------------------
      // CAS 1 : outil rectangle actif
      // ----------------------------------------------------------
      //
      // Le clic ne sert plus à sélectionner.
      // Il sert à créer une nouvelle forme.
      if (activeTool == 'rectangle') {
        // Conversion écran -> monde.
        final Offset worldPosition =
            (details.localPosition - offset) / scale;

        setState(() {
          shapes.add(
            DiagramShape(
              // ID provisoire basé sur le nombre de formes.
              //
              // Plus tard on utilisera quelque chose de plus robuste.
              id: 'rectangle-${shapes.length + 1}',

              // Le rectangle apparaît à l'endroit cliqué
              // dans le monde.
              position: worldPosition,

              // Taille par défaut provisoire.
              width: 200,
              height: 100,
            ),
          );

          // On repasse immédiatement en mode normal.
          //
          // Donc : un clic sur l'outil rectangle
          // crée UN rectangle, puis l'outil se désactive.
          activeTool = null;
        });

        return;
      }

      // ----------------------------------------------------------
      // CAS 2 : comportement normal de sélection
      // ----------------------------------------------------------
      final DiagramShape? shape =
          _shapeAtScreenPosition(details.localPosition);

      setState(() {
        selectedShape = shape;
      });

      if (shape != null) {
        debugPrint('Forme sélectionnée : ${shape.id}');
      } else {
        debugPrint('Aucune forme sélectionnée');
      }
    },

    onPanStart: (details) {
      // Au moment précis où le drag commence,
      // on regarde ce qui se trouve sous la souris.
      final DiagramShape? shape =
          _shapeAtScreenPosition(details.localPosition);

      setState(() {
        // Si une forme est sous la souris,
        // elle devient également la forme sélectionnée.
        selectedShape = shape;

        // On mémorise ce choix pour TOUTE la durée du drag.
        //
        // shape != null -> on déplacera cette forme.
        // shape == null -> on déplacera le canevas.
        draggedShape = shape;
      });
    },
      /// Cette fonction est appelée pendant un clic-glisser.
      ///
      /// details.delta représente le déplacement DEPUIS
      /// l'événement précédent.
      ///
      /// Exemple :
      /// la souris bouge de 5 px vers la droite :
      /// details.delta.dx == 5
      onPanUpdate: (details) {
        setState(() {
          if (draggedShape != null) {
            // --------------------------------------------------------
            // CAS 1 : déplacement d'une forme
            // --------------------------------------------------------
            //
            // details.delta est exprimé en pixels ÉCRAN.
            //
            // Mais la position de notre forme est exprimée
            // en coordonnées MONDE.
            //
            // Il faut donc tenir compte du zoom.
            //
            // À 100 % :
            //   10 pixels écran = 10 unités monde
            //
            // À 200 % :
            //   10 pixels écran = 5 unités monde
            //
            // À 50 % :
            //   10 pixels écran = 20 unités monde
            //
            // D'où :
            //
            //   déplacement monde = déplacement écran / scale
            final Offset worldDelta =
                details.delta / scale;
      
            draggedShape!.position += worldDelta;
          } else {
            // --------------------------------------------------------
            // CAS 2 : déplacement du canevas
            // --------------------------------------------------------
            //
            // Ici rien ne change par rapport à avant.
            //
            // offset est justement exprimé dans les coordonnées
            // de l'écran, donc aucun / scale n'est nécessaire.
            offset += details.delta;
          }
        });
      },
      onPanEnd: (details) {
        // Le bouton/doigt est relâché :
        // plus aucune forme n'est en cours de déplacement.
        draggedShape = null;
      },
      /// SizedBox.expand force son enfant
      /// à prendre toute la place disponible.
      child: SizedBox.expand(
        /// CustomPaint permet de dessiner directement sur un Canvas.
        ///
        /// C'est ici que nous allons faire une grosse partie
        /// de notre moteur de diagrammes.
        child: CustomPaint(
          /// On passe l'offset actuel au peintre.
          ///
          /// Le peintre ne modifie rien :
          /// il reçoit simplement les informations
          /// dont il a besoin pour dessiner.
            painter: GridPainter(
                offset: offset,
                scale: scale,
                shapes: shapes,
                selectedShape: selectedShape,
            ),
        ),
      ),
    )

        ),

    // Petit indicateur de zoom affiché au-dessus du canevas.
    //
    // Positioned permet de placer précisément un widget
    // dans le Stack.
    Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          // scale vaut par exemple :
          // 1.0  -> 100 %
          // 1.5  -> 150 %
          // 0.75 -> 75 %
          '${(scale * 100).round()} %',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    ),

    // Outil rectangle
    Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Rectangle',

                      // Si l'outil rectangle est actif, on affiche
                      // un fond légèrement différent.
                      style: IconButton.styleFrom(
                        backgroundColor:
                            activeTool == 'rectangle'
                                ? Colors.blue.shade100
                                : Colors.transparent,
                      ),

                      icon: const Icon(Icons.crop_square),

                      onPressed: () {
                        setState(() {
                          // Si rectangle est déjà actif, on le désactive.
                          // Sinon, on l'active.
                          activeTool =
                              activeTool == 'rectangle'
                                  ? null
                                  : 'rectangle';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
  ],
);
  }
}

/// Classe responsable du dessin de la grille.
///
/// CustomPainter donne accès à un Canvas 2D.
/// Ça ressemble beaucoup à une API de dessin classique :
/// lignes, rectangles, cercles, texte, etc.
class GridPainter extends CustomPainter {
  /// Constructeur.
  ///
  /// "required" oblige l'appelant à fournir un offset.
   GridPainter({
    required this.offset,
    required this.scale,
    required this.shapes,
    required this.selectedShape,
  });

  /// Décalage du canevas reçu depuis GridCanvas.
  final Offset offset;

  // Niveau de zoom actuel transmis par GridCanvas.
  final double scale;

  /// Formes du diagramme à dessiner.
  final List<DiagramShape> shapes;

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

      canvas.drawRect(rect, fillPaint);

      // ...puis le contour par-dessus.
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(rect, borderPaint);
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
    bool shouldRepaint(covariant GridPainter oldDelegate) {
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
