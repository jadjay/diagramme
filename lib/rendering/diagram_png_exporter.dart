import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:diagramme/models/diagram_connector.dart';
import 'package:diagramme/models/diagram_shape.dart';

/// Rend [shapes]/[connectors] en PNG à fond transparent, recadré au plus
/// près du contenu (pas de marge inutile autour).
///
/// Contrairement à une capture d'écran du canevas, ce rendu ignore
/// volontairement la grille, la croix d'origine et le surlignage de
/// sélection de [DiagramPainter] (`lib/painters/diagram_painter.dart`) :
/// seuls les formes et les connecteurs eux-mêmes sont dessinés, à leur
/// échelle "monde" (indépendamment du pan/zoom actuel du canevas).
///
/// Le contenu est dessiné directement en vectoriel à la résolution
/// demandée ([pixelRatio]) via un [Canvas] — il ne s'agit jamais
/// d'agrandir un bitmap déjà rasterisé, donc le résultat reste net (pas
/// de pixelisation) quelle que soit la taille de sortie. `2.0` (utilisé
/// par défaut) correspond à la densité d'un écran "rétina" standard :
/// suffisamment net, sans produire un fichier inutilement lourd.
///
/// Retourne `null` si [shapes] est vide (rien à exporter).
Future<Uint8List?> renderDiagramToPng(
  List<DiagramShape> shapes,
  List<DiagramConnector> connectors, {
  double padding = 24,
  double pixelRatio = 2.0,
}) async {
  if (shapes.isEmpty) {
    return null;
  }

  final Rect bounds = _boundingBoxOf(shapes).inflate(padding);

  final int pixelWidth = (bounds.width * pixelRatio).ceil();
  final int pixelHeight = (bounds.height * pixelRatio).ceil();

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // Aucun fond n'est peint ici : tout pixel non couvert par une forme
  // reste transparent dans le PNG final.
  canvas.scale(pixelRatio);
  canvas.translate(-bounds.left, -bounds.top);

  _paintConnectors(canvas, shapes, connectors);
  _paintShapes(canvas, shapes);

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(pixelWidth, pixelHeight);

  try {
    final ByteData? pngData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return pngData?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Boîte englobante (coordonnées MONDE) de toutes les formes.
Rect _boundingBoxOf(List<DiagramShape> shapes) {
  double left = double.infinity;
  double top = double.infinity;
  double right = double.negativeInfinity;
  double bottom = double.negativeInfinity;

  for (final DiagramShape shape in shapes) {
    left = left < shape.position.dx ? left : shape.position.dx;
    top = top < shape.position.dy ? top : shape.position.dy;

    final double shapeRight = shape.position.dx + shape.width;
    final double shapeBottom = shape.position.dy + shape.height;

    right = right > shapeRight ? right : shapeRight;
    bottom = bottom > shapeBottom ? bottom : shapeBottom;
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

DiagramShape? _shapeById(List<DiagramShape> shapes, String id) {
  for (final DiagramShape shape in shapes) {
    if (shape.id == id) {
      return shape;
    }
  }

  return null;
}

void _paintConnectors(
  Canvas canvas,
  List<DiagramShape> shapes,
  List<DiagramConnector> connectors,
) {
  final Paint connectorPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2.0;

  for (final DiagramConnector connector in connectors) {
    final DiagramShape? fromShape = _shapeById(shapes, connector.fromShapeId);
    final DiagramShape? toShape = _shapeById(shapes, connector.toShapeId);

    if (fromShape == null || toShape == null) {
      continue;
    }

    final Offset fromCenter = Offset(
      fromShape.position.dx + fromShape.width / 2,
      fromShape.position.dy + fromShape.height / 2,
    );

    final Offset toCenter = Offset(
      toShape.position.dx + toShape.width / 2,
      toShape.position.dy + toShape.height / 2,
    );

    canvas.drawLine(fromCenter, toCenter, connectorPaint);
  }
}

void _paintShapes(Canvas canvas, List<DiagramShape> shapes) {
  for (final DiagramShape shape in shapes) {
    final Rect rect = Rect.fromLTWH(
      shape.position.dx,
      shape.position.dy,
      shape.width,
      shape.height,
    );

    final Paint fillPaint = Paint()
      ..color = shape.fillColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = shape.strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    switch (shape.type) {
      case ShapeType.rectangle:
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);
      case ShapeType.circle:
        canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, borderPaint);
    }

    if (shape.text.isEmpty) {
      continue;
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: shape.text,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final double maxTextWidth = (shape.width - 16).clamp(1.0, double.infinity);

    textPainter.layout(maxWidth: maxTextWidth);

    final Offset textPosition = Offset(
      rect.center.dx - textPainter.width / 2,
      rect.center.dy - textPainter.height / 2,
    );

    canvas.save();
    canvas.clipRect(rect);
    textPainter.paint(canvas, textPosition);
    canvas.restore();
  }
}
