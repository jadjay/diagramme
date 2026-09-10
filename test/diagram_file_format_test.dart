import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/models/diagram_connector.dart';
import 'package:diagramme/models/diagram_document.dart';
import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/persistence/diagram_file_format.dart';

void main() {
  test(
    'encodeDiagramDocument then decodeDiagramDocument round-trips shapes, '
    'connectors, styles and multiline text',
    () {
      final document = DiagramDocument();

      final DiagramShape rectangle = document.addRectangle(
        const Offset(300, 200),
      );
      rectangle.text = 'Première ligne\nDeuxième ligne';
      rectangle.fillColor = Colors.amber.shade200;
      rectangle.strokeColor = Colors.red.shade200;

      final DiagramShape circle = document.addCircle(const Offset(600, 200));
      circle.text = 'Un cercle';
      circle.fillColor = Colors.blue.shade200;
      circle.strokeColor = Colors.green.shade200;

      document.connectors.add(
        DiagramConnector(
          id: 'connector-1',
          fromShapeId: rectangle.id,
          toShapeId: circle.id,
        ),
      );

      final String encoded = encodeDiagramDocument(document);

      final decoded = decodeDiagramDocument(encoded);

      expect(decoded.shapes, hasLength(2));

      final DiagramShape decodedRectangle = decoded.shapes[0];
      expect(decodedRectangle.id, rectangle.id);
      expect(decodedRectangle.type, ShapeType.rectangle);
      expect(decodedRectangle.position, rectangle.position);
      expect(decodedRectangle.width, rectangle.width);
      expect(decodedRectangle.height, rectangle.height);
      expect(decodedRectangle.text, rectangle.text);
      expect(decodedRectangle.fillColor, rectangle.fillColor);
      expect(decodedRectangle.strokeColor, rectangle.strokeColor);

      final DiagramShape decodedCircle = decoded.shapes[1];
      expect(decodedCircle.id, circle.id);
      expect(decodedCircle.type, ShapeType.circle);
      expect(decodedCircle.position, circle.position);
      expect(decodedCircle.width, circle.width);
      expect(decodedCircle.height, circle.height);
      expect(decodedCircle.text, circle.text);
      expect(decodedCircle.fillColor, circle.fillColor);
      expect(decodedCircle.strokeColor, circle.strokeColor);

      expect(decoded.connectors, hasLength(1));
      expect(decoded.connectors.single.id, 'connector-1');
      expect(decoded.connectors.single.fromShapeId, rectangle.id);
      expect(decoded.connectors.single.toShapeId, circle.id);
    },
  );

  test('An empty document round-trips to an empty document', () {
    final document = DiagramDocument();

    final decoded = decodeDiagramDocument(encodeDiagramDocument(document));

    expect(decoded.shapes, isEmpty);
    expect(decoded.connectors, isEmpty);
  });

  test('Shape text containing YAML-sensitive characters round-trips as-is', () {
    final document = DiagramDocument();

    final DiagramShape shape = document.addRectangle(const Offset(0, 0));
    shape.text = 'clé: valeur # commentaire "guillemets" - tiret\n---\nfin';

    final decoded = decodeDiagramDocument(encodeDiagramDocument(document));

    expect(decoded.shapes.single.text, shape.text);
  });

  test('Empty shape text round-trips as an empty string', () {
    final document = DiagramDocument();

    document.addCircle(const Offset(0, 0));

    final decoded = decodeDiagramDocument(encodeDiagramDocument(document));

    expect(decoded.shapes.single.text, '');
  });

  test('The generated Mermaid block reflects shapes and connectors', () {
    final document = DiagramDocument();

    final DiagramShape rectangle = document.addRectangle(
      const Offset(0, 0),
    );
    rectangle.text = 'Départ';

    final DiagramShape circle = document.addCircle(const Offset(100, 0));
    circle.text = 'Arrivée';

    document.connectors.add(
      DiagramConnector(
        id: 'connector-1',
        fromShapeId: rectangle.id,
        toShapeId: circle.id,
      ),
    );

    final String encoded = encodeDiagramDocument(document);

    expect(encoded, contains('```mermaid'));
    expect(encoded, contains('flowchart LR'));
    expect(encoded, contains('${rectangle.id}["Départ"]'));
    expect(encoded, contains('${circle.id}(("Arrivée"))'));
    expect(
      encoded,
      contains('${rectangle.id} --> ${circle.id}'),
    );
  });

  test(
    'decodeDiagramDocument rejects a file with an unsupported version',
    () {
      const String content = '''
---
diagramme:
  version: 999
  shapes: []
  connectors: []
---
''';

      expect(
        () => decodeDiagramDocument(content),
        throwsFormatException,
      );
    },
  );

  test('decodeDiagramDocument rejects a file without a YAML header', () {
    const String content = '# Juste un titre Markdown, sans en-tête YAML';

    expect(() => decodeDiagramDocument(content), throwsFormatException);
  });

  test('decodeDiagramDocument rejects a file with an unterminated header', () {
    const String content = '''
---
diagramme:
  version: 1
  shapes: []
  connectors: []
''';

    expect(() => decodeDiagramDocument(content), throwsFormatException);
  });
}
