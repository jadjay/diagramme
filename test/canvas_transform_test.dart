import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/models/canvas_transform.dart';

void main() {
  group('CanvasTransform', () {
    test('converts world coordinates to screen coordinates', () {
      // --------------------------------------------------------
      // ARRANGE
      // --------------------------------------------------------
      //
      // Notre monde est décalé de :
      //   +30 sur X
      //   +20 sur Y
      //
      // et zoomé à 200 %.
      const transform = CanvasTransform(
        offset: Offset(30, 20),
        scale: 2.0,
      );

      // Point fixe dans le monde.
      const worldPoint = Offset(100, 50);

      // --------------------------------------------------------
      // ACT
      // --------------------------------------------------------
      final screenPoint =
          transform.worldToScreen(worldPoint);

      // --------------------------------------------------------
      // ASSERT
      // --------------------------------------------------------
      //
      // écran = monde * scale + offset
      //
      // X :
      // 100 * 2 + 30 = 230
      //
      // Y :
      // 50 * 2 + 20 = 120
      expect(
        screenPoint,
        const Offset(230, 120),
      );
    });

    test('converts screen coordinates to world coordinates', () {
      const transform = CanvasTransform(
        offset: Offset(30, 20),
        scale: 2.0,
      );

      const screenPoint = Offset(230, 120);

      final worldPoint =
          transform.screenToWorld(screenPoint);

      expect(
        worldPoint,
        const Offset(100, 50),
      );
    });

    test('screenToWorld and worldToScreen are inverse operations', () {
      const transform = CanvasTransform(
        offset: Offset(-135, 72),
        scale: 1.75,
      );

      const originalWorldPoint =
          Offset(481.5, -237.25);

      // Monde -> écran...
      final screenPoint =
          transform.worldToScreen(originalWorldPoint);

      // ...puis écran -> monde.
      final resultingWorldPoint =
          transform.screenToWorld(screenPoint);

      // On doit retrouver exactement notre point initial.
      expect(
        resultingWorldPoint.dx,
        closeTo(originalWorldPoint.dx, 0.000001),
      );

      expect(
        resultingWorldPoint.dy,
        closeTo(originalWorldPoint.dy, 0.000001),
      );
    });
  });
}