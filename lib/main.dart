import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/diagram_connector.dart';
import 'package:diagramme/painters/diagram_painter.dart';
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

  /// Crée un rectangle à la position écran donnée.
  ///
  /// La souris nous fournit une position dans les coordonnées
  /// de l'écran.
  ///
  /// Notre modèle stocke les formes dans les coordonnées du monde.
  ///
  /// On effectue donc ici la conversion :
  ///
  ///   monde = (écran - offset) / scale
  ///
  /// Toute la logique spécifique à la création d'un rectangle
  /// est maintenant isolée dans cette méthode.
  void _createRectangle(Offset screenPosition) {
    final Offset worldPosition =
        (screenPosition - offset) / scale;

    shapes.add(
      DiagramShape(
        id: 'rectangle-${shapes.length + 1}',
        type: ShapeType.rectangle,
        position: worldPosition,
        width: 200,
        height: 100,
      ),
    );
  }


  /// Crée un cercle à la position écran donnée.
  ///
  /// Comme pour le rectangle, la position reçue appartient
  /// au système de coordonnées de l'écran.
  ///
  /// On la convertit donc en coordonnées du monde avant
  /// de créer notre objet DiagramShape.
  ///
  /// Pour l'instant, un cercle est représenté par une boîte
  /// englobante carrée de 120 × 120 unités.
  ///
  /// Comme width == height, GridPainter dessinera un vrai cercle
  /// avec drawOval().
  void _createCircle(Offset screenPosition) {
    final Offset worldPosition =
        (screenPosition - offset) / scale;
  
    shapes.add(
      DiagramShape(
        id: 'circle-${shapes.length + 1}',
        type: ShapeType.circle,
        position: worldPosition,
        width: 120,
        height: 120,
      ),
    );
  }

  /// Gère un clic utilisateur lorsque l'outil Connecteur est actif.
  ///
  /// Le workflow est volontairement simple :
  ///
  /// 1. Premier clic sur une forme
  ///    -> on mémorise la forme de départ.
  ///
  /// 2. Deuxième clic sur une autre forme
  ///    -> on crée le connecteur.
  ///
  /// 3. On réinitialise l'état temporaire.
  void _handleConnectorClick(Offset screenPosition) {
    // Cherche la forme située sous le clic.
    final DiagramShape? clickedShape =
        _shapeAtScreenPosition(screenPosition);

    // Clic dans le vide :
    // on ne fait rien et on garde l'outil connecteur actif.
    if (clickedShape == null) {
      return;
    }

    // ------------------------------------------------------------
    // PREMIER CLIC
    // ------------------------------------------------------------
    if (connectorStartShape == null) {
      connectorStartShape = clickedShape;
      selectedShape = clickedShape;

      debugPrint(
        'Début connecteur : ${clickedShape.id}',
      );

      return;
    }

    // ------------------------------------------------------------
    // DEUXIÈME CLIC
    // ------------------------------------------------------------

    // Pour l'instant, on interdit de relier une forme à elle-même.
    if (connectorStartShape!.id == clickedShape.id) {
      return;
    }

    connectors.add(
      DiagramConnector(
        id: 'connector-${connectors.length + 1}',
        fromShapeId: connectorStartShape!.id,
        toShapeId: clickedShape.id,
      ),
    );

    debugPrint(
      'Connecteur : '
      '${connectorStartShape!.id} -> ${clickedShape.id}',
    );

    // Le connecteur est terminé.
    connectorStartShape = null;

    // La deuxième forme devient la sélection courante.
    selectedShape = clickedShape;
  }

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
    // TEST final List<DiagramShape> shapes = [
    // TEST   DiagramShape(
    // TEST     id: 'circle-1',
    // TEST     type: ShapeType.circle,
    // TEST 
    // TEST     // Position du coin supérieur gauche
    // TEST     // de sa boîte englobante.
    // TEST     position: const Offset(400, 200),
    // TEST 
    // TEST     // width == height => cercle.
    // TEST     width: 120,
    // TEST     height: 120,
    // TEST   ),
    // TEST   DiagramShape(
    // TEST     id: 'rectangle-2',
    // TEST     type: ShapeType.rectangle,
    // TEST 
    // TEST     // Position du coin supérieur gauche
    // TEST     // de sa boîte englobante.
    // TEST     position: const Offset(800, 200),
    // TEST 
    // TEST     // width == height => cercle.
    // TEST     width: 120,
    // TEST     height: 120,
    // TEST   ),
    // TEST ];
    
    /// Tous les connecteurs présents dans le diagramme.
    ///
    /// Pour l'instant la liste est vide.
    /// On va bientôt y ajouter un connecteur de test.
    final List<DiagramConnector> connectors = [];
    // TEST final List<DiagramConnector> connectors = [
    // TEST   DiagramConnector(
    // TEST     id: 'connector-test',
    // TEST     fromShapeId: 'circle-1',
    // TEST     toShapeId: 'rectangle-2',
    // TEST   ),
    // TEST ];

    /// Première forme choisie lors de la création d'un connecteur.
    ///
    /// null = aucune première extrémité sélectionnée.
    ///
    /// Workflow :
    /// 1. outil connector actif
    /// 2. clic sur forme A -> connectorStartShape = A
    /// 3. clic sur forme B -> création du connecteur
    /// 4. connectorStartShape redevient null
    DiagramShape? connectorStartShape;

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
      // ------------------------------------------------------------
      // Hit-testing
      // ------------------------------------------------------------
      //
      // "Hit-testing" = déterminer si un point se trouve réellement
      // à l'intérieur d'une forme.
      //
      // worldPosition est déjà exprimé dans les coordonnées du monde.
      //
      // Donc tout le calcul qui suit est indépendant :
      // - du zoom ;
      // - du pan ;
      // - de la taille de la fenêtre.
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

          if (bounds.contains(worldPosition)) {
            return shape;
          }

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

          // Calcul des coordonnées du centre du cercle.
          final Offset center = Offset(
            shape.position.dx + radius,
            shape.position.dy + radius,
          );

          // Distance entre le point cliqué et le centre.
          //
          // Offset possède directement la propriété "distance".
          //
          // On calcule d'abord le vecteur :
          //
          //     clic - centre
          //
          // puis sa longueur.
          final double distanceFromCenter =
              (worldPosition - center).distance;

          // Géométrie toute simple :
          //
          // distance <= rayon
          //
          //             clic
          //               •
          //              /
          //             / distance
          //            /
          //           • centre
          //
          // Si la distance est inférieure au rayon,
          // le clic est dans le cercle.
          if (distanceFromCenter <= radius) {
            return shape;
          }
      }
    }

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

    /// Outil de création actuellement actif.
    ///
    /// null signifie :
    /// mode normal de sélection/déplacement.
    //ToolType? activeTool;
    ToolType activeTool = ToolType.select;

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
      // ------------------------------------------------------------
      // Gestion du clic selon l'outil actuellement actif.
      // ------------------------------------------------------------
      //
      // activeTool n'est plus nullable :
      //
      // il vaut TOUJOURS exactement l'un de ces quatre modes :
      //
      // - select
      // - rectangle
      // - circle
      // - connector
      //
      // Nous n'avons donc plus besoin :
      //
      //   if (activeTool != null)
      //
      // ni :
      //
      //   activeTool!
      //
      setState(() {
        switch (activeTool) {
          // --------------------------------------------------------
          // OUTIL SÉLECTION
          // --------------------------------------------------------
          case ToolType.select:
            // Recherche la forme située sous le clic.
            //
            // La méthode s'occupe déjà :
            // - de la conversion écran -> monde ;
            // - du rectangle ;
            // - du cercle.
            final DiagramShape? shape =
                _shapeAtScreenPosition(details.localPosition);

            // null signifie simplement que l'utilisateur
            // a cliqué dans le vide.
            selectedShape = shape;

            if (shape != null) {
              debugPrint(
                'Forme sélectionnée : ${shape.id}',
              );
            } else {
              debugPrint(
                'Aucune forme sélectionnée',
              );
            }

            break;

          // --------------------------------------------------------
          // OUTIL RECTANGLE
          // --------------------------------------------------------
          case ToolType.rectangle:
            _createRectangle(
              details.localPosition,
            );

            break;

          // --------------------------------------------------------
          // OUTIL CERCLE
          // --------------------------------------------------------
          case ToolType.circle:
            _createCircle(
              details.localPosition,
            );

            break;

          // --------------------------------------------------------
          // OUTIL CONNECTEUR
          // --------------------------------------------------------
          case ToolType.connector:
            _handleConnectorClick(
              details.localPosition,
            );

            break;
        }
      });
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
            painter: DiagramPainter(
                offset: offset,
                scale: scale,
                shapes: shapes,
                connectors: connectors,
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
                        tooltip: 'Sélection',

                        style: IconButton.styleFrom(
                          backgroundColor:
                              activeTool == ToolType.select
                                  ? Colors.blue.shade100
                                  : Colors.transparent,
                        ),

                        icon: const Icon(Icons.near_me_outlined),

                        onPressed: () {
                          setState(() {
                            activeTool = ToolType.select;

                            // Si on abandonne un connecteur en cours,
                            // on oublie sa première extrémité.
                            connectorStartShape = null;
                          });
                        },
                      ),

                      IconButton(
                       tooltip: 'Rectangle',
                                             style: IconButton.styleFrom(
                         backgroundColor:
                             activeTool == ToolType.rectangle
                                 ? Colors.blue.shade100
                                 : Colors.transparent,
                       ),
                                             icon: const Icon(Icons.crop_square),
                                             onPressed: () {
                         setState(() {
                           activeTool = ToolType.rectangle;
                         });
                       },
                      ),
                      IconButton(
                        tooltip: 'Cercle',

                        style: IconButton.styleFrom(
                          backgroundColor:
                              activeTool == ToolType.circle
                                  ? Colors.blue.shade100
                                  : Colors.transparent,
                        ),

                        icon: const Icon(Icons.circle_outlined),

                        onPressed: () {
                          setState(() {
                            activeTool = ToolType.circle;
                          });
                        },
                      ),
                      IconButton(
                        tooltip: 'Connecteur',

                        style: IconButton.styleFrom(
                          backgroundColor:
                              activeTool == ToolType.connector
                                  ? Colors.blue.shade100
                                  : Colors.transparent,
                        ),

                        icon: const Icon(Icons.arrow_right_alt),

                        onPressed: () {
                          setState(() {
                            // Active ou désactive l'outil.
                            activeTool = ToolType.connector;

                            // Si on désactive l'outil en cours de route,
                            // on oublie aussi la première forme choisie.
                            connectorStartShape = null;
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
