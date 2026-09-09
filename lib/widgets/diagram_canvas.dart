import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/diagram_document.dart';
import 'package:diagramme/models/shape_hit_tester.dart';
import 'package:diagramme/models/canvas_viewport.dart';

import 'package:diagramme/painters/diagram_painter.dart';

import 'package:diagramme/widgets/diagram_toolbar.dart';
import 'package:diagramme/widgets/zoom_indicator.dart';
import 'package:diagramme/widgets/shape_text_editor.dart';

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
    _canvasFocusNode.dispose();
    super.dispose();
  }

  /// Le contenu du diagramme (formes, connecteurs, sélection).
  ///
  /// GridCanvas ne stocke plus lui-même ces données : il se contente
  /// de traduire les gestes utilisateur (position écran, outil actif)
  /// en appels aux méthodes de [DiagramDocument], et de redessiner
  /// après chaque appel via setState().
  final DiagramDocument document = DiagramDocument();

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
  void _createRectangle(Offset screenPosition) {
    final Offset worldPosition = viewport.transform.screenToWorld(
      screenPosition,
    );

    document.addRectangle(worldPosition);
  }

  /// Crée un cercle à la position écran donnée.
  ///
  /// Comme pour le rectangle, la position reçue appartient
  /// au système de coordonnées de l'écran ; on la convertit donc
  /// en coordonnées du monde avant de créer la forme.
  void _createCircle(Offset screenPosition) {
    final Offset worldPosition = viewport.transform.screenToWorld(
      screenPosition,
    );

    document.addCircle(worldPosition);
  }

  /// Gère un clic utilisateur lorsque l'outil Connecteur est actif.
  ///
  /// Le hit-testing (trouver la forme sous le clic) reste ici, côté
  /// écran ; la logique de workflow (première/deuxième extrémité,
  /// création du connecteur) est déléguée au document.
  void _handleConnectorClick(Offset screenPosition) {
    final DiagramShape? clickedShape = _shapeAtScreenPosition(screenPosition);

    // Clic dans le vide :
    // on ne fait rien et on garde l'outil connecteur actif.
    if (clickedShape == null) {
      return;
    }

    document.handleConnectorTarget(clickedShape);
  }

  /// Pan / zoom du canevas (décalage, niveau de zoom, et les calculs
  /// qui les font évoluer en réponse à la molette ou à un geste
  /// tactile). Voir [CanvasViewport].
  final CanvasViewport viewport = CanvasViewport();

  final TextEditingController _textController = TextEditingController();

  final FocusNode _canvasFocusNode = FocusNode();

  /// Supprime la forme actuellement sélectionnée.
  ///
  /// La suppression elle-même (formes, connecteurs, état temporaire)
  /// est déléguée au document ; cette méthode ne gère que la
  /// conséquence côté UI : vider le champ de texte si la forme
  /// supprimée était en cours d'édition.
  void _deleteSelectedShape() {
    final DiagramShape? shape = document.selectedShape;

    if (shape == null) {
      return;
    }

    final bool wasEditingSelection = document.editingShape?.id == shape.id;

    document.deleteSelectedShape();

    if (wasEditingSelection) {
      _textController.clear();
    }
  }

  /// Recherche la forme située sous un point de l'écran.
  ///
  /// [screenPosition] est une position provenant de la souris,
  /// donc exprimée dans les coordonnées DE L'ÉCRAN.
  ///
  /// Nos formes, elles, sont stockées dans les coordonnées DU MONDE :
  /// on convertit donc d'abord via [CanvasViewport.transform], puis on
  /// délègue la géométrie du hit-testing à [ShapeHitTester].
  DiagramShape? _shapeAtScreenPosition(Offset screenPosition) {
    final Offset worldPosition = viewport.transform.screenToWorld(
      screenPosition,
    );

    return ShapeHitTester(document.shapes).shapeAt(worldPosition);
  }

  /// Outil de création actuellement actif.
  ///
  /// null signifie :
  /// mode normal de sélection/déplacement.
  ToolType activeTool = ToolType.select;

  /// Point focal de la frame précédente.
  ///
  /// Il nous permet de calculer le déplacement d'un doigt lorsque
  /// l'utilisateur déplace une forme (le pan/zoom du canevas lui-même
  /// est géré par [viewport], mais ce point est aussi utilisé pour le
  /// drag d'une forme — voir CAS 2 dans onScaleUpdate).
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

    setState(() {
      viewport.zoomAt(mousePosition, zoomFactor);
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
          child: KeyboardListener(
            focusNode: _canvasFocusNode,
            autofocus: true,

            onKeyEvent: (event) {
              // Pendant l'édition de texte, le clavier appartient
              // au TextField.
              //
              // Backspace doit donc supprimer une lettre,
              // pas la forme entière.
              if (document.editingShape != null) {
                return;
              }

              // On ne réagit qu'à l'appui initial.
              if (event is! KeyDownEvent) {
                return;
              }

              if (event.logicalKey == LogicalKeyboardKey.delete ||
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                setState(() {
                  _deleteSelectedShape();
                });
              }
            }, // Notre GestureDetector reste présent à l'intérieur.
            //
            // Il continue de gérer le clic-glisser exactement comme avant.
            child: GestureDetector(
              /// "opaque" signifie que toute la surface du widget
              /// capture les interactions, même si elle est visuellement vide.
              behavior: HitTestBehavior.opaque,

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
                  document.selectedShape = shape;

                  // Et on mémorise qu'elle doit être éditée.
                  document.editingShape = shape;
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
                      document.selectedShape = shape;

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

                viewport.beginGesture(details.localFocalPoint);

                _lastGestureFocalPoint = details.localFocalPoint;

                // On regarde également si le geste commence sur une forme.
                //
                // Si oui, un déplacement à UN doigt servira à déplacer
                // cette forme.
                final DiagramShape? shape = _shapeAtScreenPosition(
                  details.localFocalPoint,
                );

                setState(() {
                  document.draggedShape = shape;

                  if (shape != null) {
                    document.selectedShape = shape;
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
                    // details.scale est relatif au début du geste :
                    //
                    // 1.0 = taille inchangée
                    // 1.2 = +20 %
                    // 0.8 = -20 %
                    viewport.applyPinch(details.localFocalPoint, details.scale);

                    // Pendant un pinch, on ne déplace jamais une forme.
                    document.draggedShape = null;
                  }
                  // ----------------------------------------------------------
                  // CAS 2 : un seul doigt sur une forme
                  // ----------------------------------------------------------
                  else if (document.draggedShape != null) {
                    // Calcul du déplacement depuis la dernière frame.
                    final Offset screenDelta =
                        details.localFocalPoint - _lastGestureFocalPoint;

                    // La forme vit dans le monde.
                    //
                    // À 200 % :
                    // 10 pixels écran = 5 unités monde.
                    final Offset worldDelta = screenDelta / viewport.scale;

                    document.draggedShape!.position += worldDelta;
                  }
                  // ----------------------------------------------------------
                  // CAS 3 : un seul doigt dans le vide
                  // ----------------------------------------------------------
                  else {
                    // Un doigt sur le fond = déplacement du canevas.
                    final Offset screenDelta =
                        details.localFocalPoint - _lastGestureFocalPoint;

                    viewport.panBy(screenDelta);
                  }

                  // Le point courant devient la référence
                  // pour la prochaine frame.
                  _lastGestureFocalPoint = details.localFocalPoint;
                });
              },

              onScaleEnd: (details) {
                // Le geste est terminé.
                document.draggedShape = null;
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
                    offset: viewport.offset,
                    scale: viewport.scale,
                    shapes: document.shapes,
                    connectors: document.connectors,
                    selectedShape: document.selectedShape,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (document.editingShape != null)
          ShapeTextEditor(
            shape: document.editingShape!,
            viewport: viewport,
            controller: _textController,
            // Sauvegarde en temps réel : chaque modification du champ
            // est immédiatement copiée dans notre modèle, pour que le
            // texte ne soit jamais perdu si l'utilisateur clique
            // ailleurs ou double-tape une autre forme.
            onChanged: (value) {
              setState(() {
                document.editingShape!.text = value;
              });
            },
            // Validation : Entrée sur Linux, bouton "done" du clavier
            // sur Android.
            onSubmitted: (value) {
              setState(() {
                document.editingShape!.text = value;
                document.editingShape = null;
              });
            },
          ),

        Positioned(
          right: 16,
          bottom: 16,
          child: ZoomIndicator(scale: viewport.scale),
        ),

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
                document.connectorStartShape = null;
              });
            },
            onColorSelected: (color) {
              final DiagramShape? shape = document.selectedShape;

              if (shape == null) {
                return;
              }

              setState(() {
                shape.fillColor = color;
              });
            },
            onStrokeColorSelected: (color) {
              final DiagramShape? shape = document.selectedShape;

              if (shape == null) {
                return;
              }

              setState(() {
                shape.strokeColor = color;
              });
            },
            onDelete: () {
              setState(() {
                _deleteSelectedShape();
              });
            },
          ),
        ),
      ],
    );
  }
}
