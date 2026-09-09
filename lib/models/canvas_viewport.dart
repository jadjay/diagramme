import 'package:flutter/material.dart';

import 'package:diagramme/models/canvas_transform.dart';

/// État et logique de pan / zoom du canevas.
///
/// Cette classe possède le décalage ([offset]) et le niveau de zoom
/// ([scale]) du canevas, ainsi que le calcul qui les fait évoluer en
/// réponse à la molette de la souris ou à un geste tactile (pan à un
/// doigt, pinch-to-zoom à deux doigts).
///
/// Elle ne connaît ni les formes du diagramme, ni la sélection : c'est
/// une caméra, pas un document. GridCanvas reste responsable de
/// traduire les callbacks de gestes Flutter en appels à ces méthodes.
class CanvasViewport {
  /// Décalage actuel du canevas.
  ///
  /// Offset contient deux nombres :
  /// - dx : déplacement horizontal
  /// - dy : déplacement vertical
  ///
  /// Offset.zero signifie dx = 0, dy = 0.
  Offset offset = Offset.zero;

  /// Facteur de zoom actuel.
  ///
  /// 1.0 = 100 %
  /// 2.0 = 200 %
  /// 0.5 = 50 %
  double scale = 1.0;

  /// La transformation écran <-> monde correspondant à l'état actuel.
  CanvasTransform get transform => CanvasTransform(offset: offset, scale: scale);

  double _gestureStartScale = 1.0;
  Offset _gestureStartOffset = Offset.zero;
  Offset _gestureStartFocalPoint = Offset.zero;

  /// Zoome autour de [screenPoint] (position écran) d'un facteur
  /// [zoomFactor] — utilisé pour la molette de la souris.
  ///
  /// [screenPoint] reste visuellement sous le même point du monde
  /// après le zoom : c'est la partie importante du calcul.
  void zoomAt(Offset screenPoint, double zoomFactor) {
    // clamp() impose des limites (10 % à 500 %) : ça évite de pouvoir
    // zoomer jusqu'à zéro ou l'infini.
    final double newScale = (scale * zoomFactor).clamp(0.1, 5.0);

    // Quelle coordonnée DU MONDE se trouve actuellement sous ce point
    // de l'écran, avec le zoom actuel (avant changement) ?
    final Offset worldPointUnderScreenPoint = transform.screenToWorld(
      screenPoint,
    );

    // On recalcule offset pour que :
    //   screenPoint = worldPointUnderScreenPoint * newScale + newOffset
    offset = screenPoint - worldPointUnderScreenPoint * newScale;
    scale = newScale;
  }

  /// Démarre un geste (pan à un doigt ou pinch à deux doigts ou plus)
  /// dont le centre est [focalPoint].
  ///
  /// Mémorise l'état actuel du canevas afin que les calculs de
  /// [applyPinch] partent d'une référence stable pendant tout le
  /// geste, plutôt que de dériver frame après frame.
  void beginGesture(Offset focalPoint) {
    _gestureStartScale = scale;
    _gestureStartOffset = offset;
    _gestureStartFocalPoint = focalPoint;
  }

  /// Applique un pinch-to-zoom à deux doigts ou plus.
  ///
  /// [focalPoint] est le centre actuel du geste ; [gestureScale] est
  /// relatif au début du geste (1.0 = taille inchangée, fourni par
  /// Flutter via `ScaleUpdateDetails.scale`). Le point du monde qui
  /// se trouvait sous le centre du geste au début du pinch reste sous
  /// les doigts pendant tout le zoom.
  void applyPinch(Offset focalPoint, double gestureScale) {
    final double newScale = (_gestureStartScale * gestureScale).clamp(
      0.1,
      5.0,
    );

    final Offset worldPointUnderGesture = CanvasTransform(
      offset: _gestureStartOffset,
      scale: _gestureStartScale,
    ).screenToWorld(_gestureStartFocalPoint);

    offset = focalPoint - worldPointUnderGesture * newScale;
    scale = newScale;
  }

  /// Déplace le canevas de [screenDelta] (pan à un doigt dans le vide,
  /// ou glisser-déposer à la souris).
  void panBy(Offset screenDelta) {
    offset += screenDelta;
  }
}
