import 'package:flutter/material.dart';

import 'package:diagramme/models/diagram_shape.dart';

/// Barre d'outils principale du diagramme.
///
/// Ce widget ne décide PAS lui-même quoi faire.
/// Il reçoit :
/// - l'outil actif ;
/// - une fonction à appeler quand l'utilisateur choisit un outil.
///
/// Donc il reste purement visuel.
class DiagramToolbar extends StatefulWidget {
  const DiagramToolbar({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
    required this.onDelete,
    required this.onColorSelected,
    required this.onStrokeColorSelected,
  });

  /// Callback appelé lorsque l'utilisateur demande
  /// la suppression de la forme sélectionnée.
  final VoidCallback onDelete;

  /// Outil actuellement actif.
  final ToolType activeTool;

  /// Callback envoyé au parent lorsqu'un outil est choisi.
  final ValueChanged<ToolType> onToolSelected;

  final ValueChanged<Color> onColorSelected;
  final ValueChanged<Color> onStrokeColorSelected;

  @override
  State<DiagramToolbar> createState() => _DiagramToolbarState();
}

class _DiagramToolbarState extends State<DiagramToolbar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------------
        // Toolbar principale
        // ------------------------------------------------------------
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(blurRadius: 8, color: Color(0x22000000)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _selectionToolButton(
                tooltip: 'Sélection',
                icon: Icons.near_me_outlined,
                tool: ToolType.select,
              ),

              _selectionToolButton(
                tooltip: 'Rectangle',
                icon: Icons.crop_square,
                tool: ToolType.rectangle,
              ),

              _selectionToolButton(
                tooltip: 'Cercle',
                icon: Icons.circle_outlined,
                tool: ToolType.circle,
              ),

              _selectionToolButton(
                tooltip: 'Connecteur',
                icon: Icons.arrow_right_alt,
                tool: ToolType.connector,
              ),

              const Divider(),

              MenuAnchor(
                builder:
                    (
                      BuildContext context,
                      MenuController controller,
                      Widget? child,
                    ) {
                      return _actionToolButton(
                        tooltip: 'Couleur de remplissage',
                        icon: Icons.format_color_fill,
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },

                menuChildren: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _colorToolButton(
                        tooltip: 'Blanc',
                        color: Colors.white,
                        onPressed: () {
                          widget.onColorSelected(Colors.white);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Jaune',
                        color: Colors.amber.shade200,
                        onPressed: () {
                          widget.onColorSelected(Colors.amber.shade200);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Rouge',
                        color: Colors.red.shade200,
                        onPressed: () {
                          widget.onColorSelected(Colors.red.shade200);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Vert',
                        color: Colors.green.shade200,
                        onPressed: () {
                          widget.onColorSelected(Colors.green.shade200);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Bleu',
                        color: Colors.blue.shade200,
                        onPressed: () {
                          widget.onColorSelected(Colors.blue.shade200);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              MenuAnchor(
                builder:
                    (
                      BuildContext context,
                      MenuController controller,
                      Widget? child,
                    ) {
                      return _actionToolButton(
                        tooltip: 'Couleur de contour',
                        icon: Icons.border_color,
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },

                menuChildren: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _colorToolButton(
                        tooltip: 'Blanc',
                        color: Colors.white,
                        onPressed: () {
                          widget.onStrokeColorSelected(Colors.white);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Jaune',
                        color: Colors.amber.shade200,
                        onPressed: () {
                          widget.onStrokeColorSelected(Colors.amber.shade200);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Rouge',
                        color: Colors.red.shade200,
                        onPressed: () {
                          widget.onStrokeColorSelected(Colors.red.shade200);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Vert',
                        color: Colors.green.shade200,
                        onPressed: () {
                          widget.onStrokeColorSelected(Colors.green.shade200);
                        },
                      ),

                      _colorToolButton(
                        tooltip: 'Bleu',
                        color: Colors.blue.shade200,
                        onPressed: () {
                          widget.onStrokeColorSelected(Colors.blue.shade200);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const Divider(),

              _actionToolButton(
                tooltip: 'Supprimer',
                icon: Icons.delete_outline,
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bouton représentant un outil sélectionnable.
  ///
  /// Contrairement à une action simple, cet outil peut rester actif.
  /// L'état actif est indiqué visuellement par le fond bleu.
  Widget _selectionToolButton({
    required String tooltip,
    required IconData icon,
    required ToolType tool,
  }) {
    return IconButton(
      tooltip: tooltip,

      style: IconButton.styleFrom(
        backgroundColor: widget.activeTool == tool
            ? Colors.blue.shade100
            : Colors.transparent,
      ),

      icon: Icon(icon),

      onPressed: () {
        widget.onToolSelected(tool);
      },
    );
  }

  /// Bouton représentant une action immédiate.
  ///
  /// Une action ne reste jamais sélectionnée.
  /// Exemple : supprimer une forme.
  Widget _actionToolButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(tooltip: tooltip, icon: Icon(icon), onPressed: onPressed);
  }

  /// Bouton représentant une couleur.
  ///
  /// L'icône reste standardisée : seul son remplissage
  /// représente la couleur qui sera appliquée.
  Widget _colorToolButton({
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(Icons.circle, color: color),
      onPressed: onPressed,
    );
  }
}
