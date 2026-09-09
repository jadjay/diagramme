import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/canvas_viewport.dart';

/// Champ de texte multiligne superposé au-dessus de la forme en cours
/// d'édition.
///
/// Ce widget ne gère aucun état lui-même : il se contente de
/// positionner un [TextField] à l'écran, à l'endroit où se trouve
/// [shape] compte tenu du pan/zoom actuel du canevas ([viewport]), et
/// de relayer les changements via [onChanged] / [onSubmitted].
///
/// Le champ est multiligne (`maxLines: null`) : Entrée insère un
/// retour à la ligne plutôt que de valider. L'édition se termine par :
/// - un clic à l'extérieur du champ ([TapRegion.onTapOutside]) ;
/// - Ctrl+Entrée ;
/// - un "done" explicite envoyé par la plateforme (`onSubmitted`,
///   conservé pour les claviers logiciels qui l'exposeraient encore).
class ShapeTextEditor extends StatelessWidget {
  const ShapeTextEditor({
    super.key,
    required this.shape,
    required this.viewport,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  /// Forme actuellement éditée. Sa position/taille (coordonnées MONDE)
  /// détermine où placer le champ à l'écran.
  final DiagramShape shape;

  /// Pan/zoom actuel du canevas, pour convertir [shape] en coordonnées
  /// écran : écran = monde * scale + offset.
  final CanvasViewport viewport;

  final TextEditingController controller;

  /// Appelé à chaque frappe : GridCanvas copie la valeur dans le
  /// modèle en temps réel, pour ne jamais perdre de texte.
  final ValueChanged<String> onChanged;

  /// Appelé pour valider et terminer l'édition (clic extérieur,
  /// Ctrl+Entrée, ou "done" explicite de la plateforme).
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // shape.position est en coordonnées MONDE.
      //
      // écran = monde * scale + offset
      //
      // Le champ est aligné sur le coin haut-gauche de la forme et
      // grandit vers le bas au fil des lignes : sa hauteur n'est plus
      // fixe comme en mode mono-ligne.
      left: shape.position.dx * viewport.scale + viewport.offset.dx,
      top: shape.position.dy * viewport.scale + viewport.offset.dy,

      // L'éditeur prend la largeur actuelle de la forme.
      width: shape.width * viewport.scale,
      child: TapRegion(
        // Un clic en dehors de ce widget valide et termine l'édition.
        //
        // TapRegion gère lui-même la distinction "dedans / dehors"
        // (y compris pour un clic à l'intérieur du champ pendant la
        // frappe, qui ne doit PAS terminer l'édition) sans qu'on ait
        // à recalculer manuellement la zone du champ, qui grandit
        // avec le texte.
        onTapOutside: (_) => onSubmitted(controller.text),
        child: Focus(
          // Intercepte Ctrl+Entrée avant l'EditableText : Entrée seule
          // doit rester un retour à la ligne normal.
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter &&
                HardwareKeyboard.instance.isControlPressed) {
              onSubmitted(controller.text);

              return KeyEventResult.handled;
            }

            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: controller,

            autofocus: true,

            // Champ multiligne : Entrée insère un retour à la ligne
            // au lieu de valider (comportement par défaut de
            // TextField dès que maxLines != 1).
            maxLines: null,

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

            // Sauvegarde en temps réel : chaque modification du champ
            // est immédiatement copiée dans notre modèle, pour que le
            // texte ne soit jamais perdu.
            onChanged: onChanged,

            // Conservé pour un éventuel "done" explicite de la
            // plateforme ; n'est plus déclenché par la touche Entrée
            // elle-même une fois le champ multiligne.
            onSubmitted: onSubmitted,
          ),
        ),
      ),
    );
  }
}
