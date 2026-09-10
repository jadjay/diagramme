import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/models/diagram_connector.dart';
import 'package:diagramme/models/diagram_document.dart';
import 'package:diagramme/models/diagram_shape.dart';

void main() {
  test('replaceContent replaces shapes, connectors and clears selection state', () {
    final document = DiagramDocument();

    final DiagramShape original = document.addRectangle(const Offset(0, 0));
    document.selectedShape = original;
    document.editingShape = original;
    document.draggedShape = original;
    document.resizingShape = original;

    final DiagramShape loadedShape = DiagramShape(
      id: 'shape-42',
      type: ShapeType.circle,
      position: const Offset(10, 20),
      width: 80,
      height: 80,
    );

    final DiagramConnector loadedConnector = DiagramConnector(
      id: 'connector-1',
      fromShapeId: 'shape-42',
      toShapeId: 'shape-42',
    );

    document.replaceContent([loadedShape], [loadedConnector]);

    expect(document.shapes, [loadedShape]);
    expect(document.connectors, [loadedConnector]);
    expect(document.selectedShape, isNull);
    expect(document.editingShape, isNull);
    expect(document.draggedShape, isNull);
    expect(document.resizingShape, isNull);
  });

  test(
    'replaceContent resumes shape id numbering after the highest loaded id, '
    'so newly created shapes never collide with a loaded one',
    () {
      final document = DiagramDocument();

      document.replaceContent([
        DiagramShape(
          id: 'shape-7',
          type: ShapeType.rectangle,
          position: const Offset(0, 0),
          width: 100,
          height: 100,
        ),
        DiagramShape(
          id: 'shape-3',
          type: ShapeType.circle,
          position: const Offset(0, 0),
          width: 100,
          height: 100,
        ),
      ], []);

      final DiagramShape newShape = document.addRectangle(
        const Offset(0, 0),
      );

      expect(newShape.id, 'shape-8');
    },
  );

  test(
    'replaceContent falls back to numbering from 1 when no loaded id '
    'follows the shape-N pattern',
    () {
      final document = DiagramDocument();

      document.replaceContent([
        DiagramShape(
          id: 'imported-from-elsewhere',
          type: ShapeType.rectangle,
          position: const Offset(0, 0),
          width: 100,
          height: 100,
        ),
      ], []);

      final DiagramShape newShape = document.addRectangle(
        const Offset(0, 0),
      );

      expect(newShape.id, 'shape-1');
    },
  );
}
