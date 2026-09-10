import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/models/diagram_connector.dart';
import 'package:diagramme/models/diagram_shape.dart';
import 'package:diagramme/rendering/diagram_png_exporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renderDiagramToPng returns null for an empty diagram', () async {
    final Uint8List? bytes = await renderDiagramToPng([], []);

    expect(bytes, isNull);
  });

  test(
    'renderDiagramToPng produces a valid PNG, sized to the shapes plus '
    'padding, with a transparent background',
    () async {
      final DiagramShape rectangle = DiagramShape(
        id: 'shape-1',
        type: ShapeType.rectangle,
        position: const Offset(0, 0),
        width: 100,
        height: 50,
        fillColor: Colors.red,
      );

      final DiagramShape circle = DiagramShape(
        id: 'shape-2',
        type: ShapeType.circle,
        position: const Offset(200, 0),
        width: 60,
        height: 60,
        fillColor: Colors.blue,
      );

      final Uint8List? bytes = await renderDiagramToPng(
        [rectangle, circle],
        [
          DiagramConnector(
            id: 'connector-1',
            fromShapeId: rectangle.id,
            toShapeId: circle.id,
          ),
        ],
        padding: 10,
        pixelRatio: 2.0,
      );

      expect(bytes, isNotNull);

      // Un PNG commence toujours par cette signature d'octets.
      const List<int> pngSignature = [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ];

      expect(bytes!.sublist(0, 8), pngSignature);

      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      // Boîte englobante des deux formes : (0, 0) à (260, 60), plus 10
      // de marge de chaque côté -> 280 x 80 en coordonnées monde, soit
      // 560 x 160 pixels à pixelRatio 2.0.
      expect(image.width, 560);
      expect(image.height, 160);

      final ByteData? pixels = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      expect(pixels, isNotNull);

      // Coin haut-gauche de l'image : dans la marge, donc entièrement
      // transparent (canal alpha à 0).
      expect(pixels!.getUint8(3), 0);

      image.dispose();
      codec.dispose();
    },
  );
}
