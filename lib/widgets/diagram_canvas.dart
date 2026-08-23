import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/diagram_connector.dart';
import 'package:diagramme/models/canvas_transform.dart';

import 'package:diagramme/painters/diagram_painter.dart';

import 'package:diagramme/widgets/diagram_toolbar.dart';
import 'package:diagramme/widgets/zoom_indicator.dart';

/// Notre zone de dessin.
///
/// StatefulWidget = widget qui possède un état mutable.
///
/// Ici, l'état à mémoriser est la position de la grille.
/// Quand l'utilisateur déplace la souris, cette position change.
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
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
    final transform = CanvasTransform(offset: offset, scale: scale);

    final Offset worldPosition = transform.screenToWorld(screenPosition);
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
    final transform = CanvasTransform(offset: offset, scale: scale);

    final Offset worldPosition = transform.screenToWorld(screenPosition);

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
    final DiagramShape? clickedShape = _shapeAtScreenPosition(screenPosition);

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

      // debugPrint(
      //   'Début connecteur : ${clickedShape.id}',
      // );

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

    // debugPrint(
    //   'Connecteur : '
    //   '${connectorStartShape!.id} -> ${clickedShape.id}',
    // );

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
  // final List<DiagramShape> shapes = [
  //   DiagramShape(
  //     id: 'circle-1',
  //     type: ShapeType.circle,
  //
  //     // Position du coin supérieur gauche
  //     // de sa boîte englobante.
  //     position: const Offset(400, 200),
  //
  //     // width == height => cercle.
  //     width: 120,
  //     height: 120,
  //     text: 'Hello',
  //
  //   ),
  // ];
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

  /// Forme actuellement en cours d'édition de texte.
  ///
  /// null = aucune édition en cours.
  ///
  /// Cette variable servira ensuite à afficher un TextField
  /// superposé au-dessus de la forme.
  DiagramShape? editingShape;

  final TextEditingController _textController = TextEditingController();

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
    final transform = CanvasTransform(offset: offset, scale: scale);

    final Offset worldPosition = transform.screenToWorld(screenPosition);

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
          final double distanceFromCenter = (worldPosition - center).distance;

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

  /// État mémorisé au début d'un geste tactile.
  ///
  /// Un geste "scale" Flutter peut représenter :
  ///
  /// - un drag avec un seul doigt ;
  /// - un pinch avec deux doigts ;
  /// - un pinch + déplacement simultané.
  double _gestureStartScale = 1.0;

  Offset _gestureStartOffset = Offset.zero;

  /// Point focal au début du geste.
  ///
  /// Avec un doigt : position du doigt.
  /// Avec deux doigts : point situé entre les deux doigts.
  Offset _gestureStartFocalPoint = Offset.zero;

  /// Point focal de la frame précédente.
  ///
  /// Il nous permet de calculer le déplacement d'un doigt
  /// lorsque l'utilisateur déplace une forme.
  Offset _lastGestureFocalPoint = Offset.zero;

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
    final double zoomFactor = event.scrollDelta.dy < 0 ? 1.1 : 1 / 1.1;

    // On calcule le nouveau niveau de zoom.
    //
    // clamp() impose des limites :
    //   0.1 = 10 %
    //   5.0 = 500 %
    //
    // Ça évite de pouvoir zoomer jusqu'à zéro ou l'infini.
    final double newScale = (scale * zoomFactor).clamp(0.1, 5.0);

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
    final Offset worldPointUnderMouse = (mousePosition - offset) / scale;

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
    final Offset newOffset = mousePosition - worldPointUnderMouse * newScale;

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
            onDoubleTapDown: (details) {
              // ------------------------------------------------------------
              // Double clic / double tap
              // ------------------------------------------------------------
              //
              // On ne veut éditer du texte que lorsqu'on utilise
              // l'outil Sélection.
              if (activeTool != ToolType.select) {
                return;
              }

              // Recherche la forme située sous le double clic/tap.
              final DiagramShape? shape = _shapeAtScreenPosition(
                details.localPosition,
              );

              // Double clic dans le vide :
              // aucune édition.
              if (shape == null) {
                return;
              }

              _textController.text = shape.text;

              setState(() {
                // On sélectionne également la forme.
                selectedShape = shape;

                // Et on mémorise qu'elle doit être éditée.
                editingShape = shape;

                // debugPrint('Édition texte : ${shape.id}');
              });
            },

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
                    final DiagramShape? shape = _shapeAtScreenPosition(
                      details.localPosition,
                    );

                    // null signifie simplement que l'utilisateur
                    // a cliqué dans le vide.
                    selectedShape = shape;

                    // if (shape != null) {
                    //   debugPrint('Forme sélectionnée : ${shape.id}');
                    // } else {
                    //   debugPrint('Aucune forme sélectionnée');
                    // }

                    break;

                  // --------------------------------------------------------
                  // OUTIL RECTANGLE
                  // --------------------------------------------------------
                  case ToolType.rectangle:
                    _createRectangle(details.localPosition);

                    break;

                  // --------------------------------------------------------
                  // OUTIL CERCLE
                  // --------------------------------------------------------
                  case ToolType.circle:
                    _createCircle(details.localPosition);

                    break;

                  // --------------------------------------------------------
                  // OUTIL CONNECTEUR
                  // --------------------------------------------------------
                  case ToolType.connector:
                    _handleConnectorClick(details.localPosition);

                    break;
                }
              });
            },

            onScaleStart: (details) {
              // ------------------------------------------------------------
              // Début d'un geste
              // ------------------------------------------------------------
              //
              // GestureDetector utilise "scale" aussi bien pour :
              //
              // - un drag à un doigt ;
              // - un pinch à deux doigts.
              //
              // On mémorise donc l'état actuel du canevas afin que tous
              // les calculs suivants partent d'une référence stable.

              _gestureStartScale = scale;
              _gestureStartOffset = offset;

              _gestureStartFocalPoint = details.localFocalPoint;

              _lastGestureFocalPoint = details.localFocalPoint;

              // On regarde également si le geste commence sur une forme.
              //
              // Si oui, un déplacement à UN doigt servira à déplacer
              // cette forme.
              final DiagramShape? shape = _shapeAtScreenPosition(
                details.localFocalPoint,
              );

              setState(() {
                draggedShape = shape;

                if (shape != null) {
                  selectedShape = shape;
                }
              });
            },

            onScaleUpdate: (details) {
              setState(() {
                // ----------------------------------------------------------
                // CAS 1 : deux doigts ou plus
                // ----------------------------------------------------------
                //
                // Dans ce cas, on considère toujours que l'utilisateur
                // manipule le CANEVAS et non une forme.
                //
                // C'est notre pinch-to-zoom Android.
                if (details.pointerCount >= 2) {
                  // Nouveau niveau de zoom.
                  //
                  // details.scale est relatif au début du geste :
                  //
                  // 1.0 = taille inchangée
                  // 1.2 = +20 %
                  // 0.8 = -20 %
                  final double newScale = (_gestureStartScale * details.scale)
                      .clamp(0.1, 5.0);

                  // --------------------------------------------------------
                  // Trouver quel point DU MONDE se trouvait sous
                  // le centre du geste au début du pinch.
                  // --------------------------------------------------------
                  //
                  // monde = (écran - offset) / scale
                  final Offset worldPointUnderGesture =
                      (_gestureStartFocalPoint - _gestureStartOffset) /
                      _gestureStartScale;

                  // --------------------------------------------------------
                  // Recalcul de l'offset
                  // --------------------------------------------------------
                  //
                  // On veut que ce même point du monde reste sous
                  // les doigts pendant le zoom.
                  //
                  // écran = monde * scale + offset
                  //
                  // donc :
                  //
                  // offset = écran - monde * scale
                  offset =
                      details.localFocalPoint -
                      worldPointUnderGesture * newScale;

                  scale = newScale;

                  // Pendant un pinch, on ne déplace jamais une forme.
                  draggedShape = null;
                }
                // ----------------------------------------------------------
                // CAS 2 : un seul doigt sur une forme
                // ----------------------------------------------------------
                else if (draggedShape != null) {
                  // Calcul du déplacement depuis la dernière frame.
                  final Offset screenDelta =
                      details.localFocalPoint - _lastGestureFocalPoint;

                  // La forme vit dans le monde.
                  //
                  // À 200 % :
                  // 10 pixels écran = 5 unités monde.
                  final Offset worldDelta = screenDelta / scale;

                  draggedShape!.position += worldDelta;
                }
                // ----------------------------------------------------------
                // CAS 3 : un seul doigt dans le vide
                // ----------------------------------------------------------
                else {
                  // Un doigt sur le fond = déplacement du canevas.
                  final Offset screenDelta =
                      details.localFocalPoint - _lastGestureFocalPoint;

                  offset += screenDelta;
                }

                // Le point courant devient la référence
                // pour la prochaine frame.
                _lastGestureFocalPoint = details.localFocalPoint;
              });
            },

            onScaleEnd: (details) {
              // Le geste est terminé.
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
          ),
        ),

        if (editingShape != null)
          Positioned(
            // ----------------------------------------------------------
            // Position écran de la forme en cours d'édition
            // ----------------------------------------------------------
            //
            // shape.position est en coordonnées MONDE.
            //
            // écran = monde * scale + offset
            left: editingShape!.position.dx * scale + offset.dx,

            // Centre verticalement le champ dans la forme.
            top:
                editingShape!.position.dy * scale +
                offset.dy +
                (editingShape!.height * scale - 48.0) / 2,

            // L'éditeur prend la largeur actuelle de la forme.
            width: editingShape!.width * scale,
            height: 48.0,
            child: TextField(
              controller: _textController,

              autofocus: true,

              textAlign: TextAlign.center,

              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),

              // --------------------------------------------------------
              // Sauvegarde en temps réel
              // --------------------------------------------------------
              //
              // Chaque modification du champ est immédiatement
              // copiée dans notre modèle.
              //
              // Ainsi, si l'utilisateur :
              //
              // - tape du texte ;
              // - clique ailleurs ;
              // - double-tape une autre forme ;
              //
              // le texte n'est jamais perdu.
              onChanged: (value) {
                setState(() {
                  editingShape!.text = value;
                });
              },

              // --------------------------------------------------------
              // Validation
              // --------------------------------------------------------
              //
              // Linux :
              // Entrée valide.
              //
              // Android :
              // le bouton "done" du clavier valide.
              onSubmitted: (value) {
                setState(() {
                  editingShape!.text = value;
                  editingShape = null;
                });
              },
            ),
          ),

        Positioned(right: 16, bottom: 16, child: ZoomIndicator(scale: scale)),

        Positioned(
          left: 16,
          top: 16,
          child: DiagramToolbar(
            activeTool: activeTool,

            onToolSelected: (tool) {
              setState(() {
                activeTool = tool;

                // Si on quitte ou réactive le mode connecteur,
                // on repart sans première extrémité mémorisée.
                connectorStartShape = null;
              });
            },
          ),
        ),
      ],
    );
  }
}
