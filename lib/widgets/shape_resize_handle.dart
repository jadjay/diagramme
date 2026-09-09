import 'package:flutter/material.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/canvas_viewport.dart';

/// Poignée de redimensionnement affichée au coin bas-droit de la forme
/// sélectionnée.
///
/// Contrairement à la première version, ce widget gère son propre
/// geste de bout en bout via un [Listener] dédié, au lieu de compter
/// sur le GestureDetector unique de GridCanvas pour détecter par
/// hit-testing qu'un geste démarre sur la poignée.
///
/// Cette dépendance à deux vérifications séparées (onTapDown ET
/// onScaleStart devaient chacun retomber sur les mêmes coordonnées)
/// se révélait peu fiable sur un appareil réel : la moindre imprécision
/// tactile ou souris faisait que l'un des deux hit-tests ratait la
/// poignée, désélectionnant la forme avant même que le
/// redimensionnement ait pu démarrer — en particulier pour un cercle,
/// dont le coin de la boîte englobante (là où se trouve la poignée)
/// est géométriquement à l'EXTÉRIEUR du disque visible, donc jamais
/// "dans" la forme au sens de ShapeHitTester.
///
/// [Listener] ne participe pas à l'arène de gestes (contrairement à
/// GestureDetector) : ses callbacks se déclenchent de façon fiable et
/// indépendante, sans avoir à s'accorder avec un autre recognizer sur
/// les mêmes coordonnées exactes. La zone de détection ([_hitSize])
/// est en outre bien plus généreuse que le disque affiché
/// ([_visualSize]), pour rester facile à attraper au doigt.
class ShapeResizeHandle extends StatelessWidget {
  const ShapeResizeHandle({
    super.key,
    required this.shape,
    required this.viewport,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
  });

  /// Forme actuellement sélectionnée, dont on affiche la poignée.
  final DiagramShape shape;

  /// Pan/zoom actuel du canevas, pour convertir [shape] en coordonnées
  /// écran.
  final CanvasViewport viewport;

  /// Appelé au tout début du drag (pointeur pressé sur la poignée).
  final VoidCallback onResizeStart;

  /// Appelé à chaque déplacement du pointeur pendant le drag, avec le
  /// delta déjà converti en coordonnées MONDE.
  final ValueChanged<Offset> onResizeUpdate;

  /// Appelé à la fin du drag (relâchement ou annulation du pointeur).
  final VoidCallback onResizeEnd;

  /// Diamètre du disque affiché.
  static const double _visualSize = 14.0;

  /// Diamètre de la zone réellement cliquable/touchable : plus
  /// généreuse que le disque affiché (recommandation usuelle : cibles
  /// tactiles d'au moins ~44 unités logiques).
  static const double _hitSize = 44.0;

  /// Centre de la poignée, en coordonnées ÉCRAN — coin bas-droit de la
  /// boîte englobante de [shape] (position + largeur/hauteur), converti
  /// via [viewport].
  static Offset screenCenter(DiagramShape shape, CanvasViewport viewport) {
    return Offset(
      (shape.position.dx + shape.width) * viewport.scale + viewport.offset.dx,
      (shape.position.dy + shape.height) * viewport.scale + viewport.offset.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Offset center = screenCenter(shape, viewport);

    return Positioned(
      left: center.dx - _hitSize / 2,
      top: center.dy - _hitSize / 2,
      width: _hitSize,
      height: _hitSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpLeftDownRight,
        child: Listener(
          // "opaque" : la zone entière capture les pointeurs, même
          // là où rien n'est peint (le disque est plus petit que la
          // zone de détection).
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => onResizeStart(),
          onPointerMove: (event) => onResizeUpdate(event.delta / viewport.scale),
          onPointerUp: (_) => onResizeEnd(),
          onPointerCancel: (_) => onResizeEnd(),
          child: Center(
            child: Container(
              width: _visualSize,
              height: _visualSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
