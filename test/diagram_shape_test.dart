import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/models/diagram_shape.dart';

void main() {
  group('DiagramShape.resizeBy', () {
    test('grows a rectangle independently on each axis', () {
      // --------------------------------------------------------
      // ARRANGE
      // --------------------------------------------------------
      final rectangle = DiagramShape(
        id: 'rectangle-1',
        type: ShapeType.rectangle,
        position: const Offset(0, 0),
        width: 200,
        height: 100,
      );

      // --------------------------------------------------------
      // ACT
      // --------------------------------------------------------
      rectangle.resizeBy(const Offset(50, 10));

      // --------------------------------------------------------
      // ASSERT
      // --------------------------------------------------------
      expect(rectangle.width, 250);
      expect(rectangle.height, 110);

      // La position (coin haut-gauche) ne bouge jamais : on
      // redimensionne depuis le coin bas-droit.
      expect(rectangle.position, Offset.zero);
    });

    test('shrinks a rectangle but never below the minimum size', () {
      final rectangle = DiagramShape(
        id: 'rectangle-1',
        type: ShapeType.rectangle,
        position: const Offset(0, 0),
        width: 200,
        height: 100,
      );

      // Un delta largement négatif devrait normalement produire des
      // dimensions négatives : minSize doit l'en empêcher.
      rectangle.resizeBy(const Offset(-1000, -1000));

      expect(rectangle.width, DiagramShape.minSize);
      expect(rectangle.height, DiagramShape.minSize);
    });

    test('keeps a circle width equal to its height', () {
      final circle = DiagramShape(
        id: 'circle-1',
        type: ShapeType.circle,
        position: const Offset(0, 0),
        width: 120,
        height: 120,
      );

      // Un delta volontairement différent sur X et Y : le cercle doit
      // quand même rester "rond" (width == height).
      circle.resizeBy(const Offset(40, 20));

      expect(circle.width, circle.height);

      // La nouvelle taille correspond à la moyenne du delta appliqué
      // à la taille d'origine : 120 + (40 + 20) / 2 = 150.
      expect(circle.width, 150);
    });

    test('shrinks a circle but never below the minimum size', () {
      final circle = DiagramShape(
        id: 'circle-1',
        type: ShapeType.circle,
        position: const Offset(0, 0),
        width: 120,
        height: 120,
      );

      circle.resizeBy(const Offset(-1000, -1000));

      expect(circle.width, DiagramShape.minSize);
      expect(circle.height, DiagramShape.minSize);
    });
  });
}
