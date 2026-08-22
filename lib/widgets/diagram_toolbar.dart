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
class DiagramToolbar extends StatelessWidget {
  const DiagramToolbar({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
  });

  /// Outil actuellement actif.
  final ToolType activeTool;

  /// Callback envoyé au parent lorsqu'un outil est choisi.
  final ValueChanged<ToolType> onToolSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _toolButton(
            tooltip: 'Sélection',
            icon: Icons.near_me_outlined,
            tool: ToolType.select,
          ),
          _toolButton(
            tooltip: 'Rectangle',
            icon: Icons.crop_square,
            tool: ToolType.rectangle,
          ),
          _toolButton(
            tooltip: 'Cercle',
            icon: Icons.circle_outlined,
            tool: ToolType.circle,
          ),
          _toolButton(
            tooltip: 'Connecteur',
            icon: Icons.arrow_right_alt,
            tool: ToolType.connector,
          ),
        ],
      ),
    );
  }

  /// Fabrique un bouton de la toolbar.
  ///
  /// Cela évite de répéter quatre fois le même IconButton.
  Widget _toolButton({
    required String tooltip,
    required IconData icon,
    required ToolType tool,
  }) {
    return IconButton(
      tooltip: tooltip,

      style: IconButton.styleFrom(
        backgroundColor:
            activeTool == tool
                ? Colors.blue.shade100
                : Colors.transparent,
      ),

      icon: Icon(icon),

      onPressed: () {
        onToolSelected(tool);
      },
    );
  }
}