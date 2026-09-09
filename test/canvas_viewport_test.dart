import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/models/canvas_viewport.dart';

void main() {
  group('CanvasViewport', () {
    test('zoomAt updates scale and offset as expected', () {
      // --------------------------------------------------------
      // ARRANGE
      // --------------------------------------------------------
      final viewport = CanvasViewport();

      // --------------------------------------------------------
      // ACT
      // --------------------------------------------------------
      viewport.zoomAt(const Offset(100, 50), 2.0);

      // --------------------------------------------------------
      // ASSERT
      // --------------------------------------------------------
      //
      // Avant zoom : offset (0,0), scale 1.0.
      // Le point du monde sous (100, 50) est donc (100, 50).
      //
      // newOffset = screenPoint - worldPoint * newScale
      //           = (100, 50) - (100, 50) * 2
      //           = (-100, -50)
      expect(viewport.scale, 2.0);
      expect(viewport.offset, const Offset(-100, -50));
    });

    test('zoomAt keeps the same world point under the screen point', () {
      final viewport = CanvasViewport()
        ..offset = const Offset(30, 20)
        ..scale = 1.5;

      const screenPoint = Offset(200, 150);

      final worldBefore = viewport.transform.screenToWorld(screenPoint);

      viewport.zoomAt(screenPoint, 1.3);

      final worldAfter = viewport.transform.screenToWorld(screenPoint);

      expect(worldAfter.dx, closeTo(worldBefore.dx, 0.000001));
      expect(worldAfter.dy, closeTo(worldBefore.dy, 0.000001));
    });

    test('zoomAt clamps the scale between 0.1 and 5.0', () {
      final zoomedIn = CanvasViewport()..zoomAt(Offset.zero, 100);
      expect(zoomedIn.scale, 5.0);

      final zoomedOut = CanvasViewport()..zoomAt(Offset.zero, 0.001);
      expect(zoomedOut.scale, 0.1);
    });

    test('applyPinch scales and recenters around the gesture focal point', () {
      final viewport = CanvasViewport()..offset = const Offset(10, 10);

      viewport.beginGesture(const Offset(100, 100));
      viewport.applyPinch(const Offset(120, 110), 2.0);

      // Au début du geste : offset (10,10), scale 1.0.
      // Le point du monde sous le focal point (100,100) est (90, 90).
      //
      // newOffset = focalPoint - worldPoint * newScale
      //           = (120, 110) - (90, 90) * 2
      //           = (-60, -70)
      expect(viewport.scale, 2.0);
      expect(viewport.offset, const Offset(-60, -70));
    });

    test('applyPinch clamps the scale between 0.1 and 5.0', () {
      final viewport = CanvasViewport();

      viewport.beginGesture(Offset.zero);
      viewport.applyPinch(Offset.zero, 50);

      expect(viewport.scale, 5.0);
    });

    test('panBy translates the offset by the given screen delta', () {
      final viewport = CanvasViewport()..offset = const Offset(5, 5);

      viewport.panBy(const Offset(10, -4));

      expect(viewport.offset, const Offset(15, 1));
    });
  });
}
