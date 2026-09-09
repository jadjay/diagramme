import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/models/shape_hit_tester.dart';

void main() {
  group('ShapeHitTester', () {
    test('finds a rectangle when the point is inside its bounds', () {
      // --------------------------------------------------------
      // ARRANGE
      // --------------------------------------------------------
      final rectangle = DiagramShape(
        id: 'rectangle-1',
        type: ShapeType.rectangle,
        position: const Offset(100, 100),
        width: 200,
        height: 100,
      );

      final tester = ShapeHitTester([rectangle]);

      // --------------------------------------------------------
      // ACT + ASSERT
      // --------------------------------------------------------
      expect(tester.shapeAt(const Offset(150, 150)), rectangle);
    });

    test('misses a rectangle when the point is outside its bounds', () {
      final rectangle = DiagramShape(
        id: 'rectangle-1',
        type: ShapeType.rectangle,
        position: const Offset(100, 100),
        width: 200,
        height: 100,
      );

      final tester = ShapeHitTester([rectangle]);

      expect(tester.shapeAt(const Offset(50, 50)), isNull);
    });

    test('finds a circle when the point is within its radius', () {
      // Cercle : boîte englobante 400,200 -> 120x120,
      // donc centre (460, 260) et rayon 60.
      final circle = DiagramShape(
        id: 'circle-1',
        type: ShapeType.circle,
        position: const Offset(400, 200),
        width: 120,
        height: 120,
      );

      final tester = ShapeHitTester([circle]);

      // Point à l'intérieur du cercle mais hors de sa boîte englobante
      // "coin" (400,200) : vérifie qu'on teste bien la distance au
      // centre, pas juste le rectangle englobant.
      expect(tester.shapeAt(const Offset(460, 260)), circle);
    });

    test('misses a circle when the point is in its bounding box corner', () {
      // Même cercle que ci-dessus : le coin (400,200) de la boîte
      // englobante est hors du cercle (distance au centre > rayon).
      final circle = DiagramShape(
        id: 'circle-1',
        type: ShapeType.circle,
        position: const Offset(400, 200),
        width: 120,
        height: 120,
      );

      final tester = ShapeHitTester([circle]);

      expect(tester.shapeAt(const Offset(400, 200)), isNull);
    });

    test('picks the topmost shape when two shapes overlap', () {
      // Deux rectangles superposés : le second, dessiné par-dessus,
      // doit être celui retourné.
      final bottom = DiagramShape(
        id: 'bottom',
        type: ShapeType.rectangle,
        position: const Offset(0, 0),
        width: 100,
        height: 100,
      );

      final top = DiagramShape(
        id: 'top',
        type: ShapeType.rectangle,
        position: const Offset(0, 0),
        width: 100,
        height: 100,
      );

      final tester = ShapeHitTester([bottom, top]);

      expect(tester.shapeAt(const Offset(50, 50)), top);
    });

    test('returns null when no shape contains the point', () {
      final tester = ShapeHitTester(const []);

      expect(tester.shapeAt(const Offset(0, 0)), isNull);
    });
  });
}
