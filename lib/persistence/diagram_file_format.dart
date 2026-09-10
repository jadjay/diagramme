import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';

import 'package:diagramme/models/diagram_connector.dart';
import 'package:diagramme/models/diagram_document.dart';
import 'package:diagramme/models/diagram_shape.dart';

/// Format de fichier de sauvegarde de Diagramme : extension `.dgm.md`.
///
/// Un fichier `.dgm.md` est un document Markdown normal, composé de deux
/// parties :
///
/// 1. un en-tête YAML (frontmatter, délimité par `---`), qui reste la
///    SEULE source de vérité relue par [decodeDiagramDocument] : formes,
///    connecteurs, positions, tailles, couleurs et textes ;
/// 2. un bloc ```mermaid``` régénéré à chaque sauvegarde à partir de ce
///    même contenu, qui n'est PAS relu au chargement (il est ignoré par
///    [decodeDiagramDocument]) mais permet au fichier de s'afficher comme
///    un vrai diagramme dans n'importe quel lecteur Markdown qui sait
///    rendre Mermaid (GitHub, GitLab, Obsidian, VS Code...).
///
/// Ouvert comme simple fichier texte, le fichier reste lisible : les
/// textes des formes sont stockés en clair (bloc littéral YAML `|`, sans
/// caractère d'échappement), directement réutilisables tels quels dans un
/// document Markdown ou LaTeX.
///
/// Exemple :
///
/// ```markdown
/// ---
/// diagramme:
///   version: 1
///   shapes:
///     - id: shape-1
///       type: rectangle
///       position: {x: 300.0, y: 200.0}
///       size: {width: 200.0, height: 100.0}
///       fillColor: "#FFFFFF"
///       strokeColor: "#000000"
///       text: |2-
///         Mon texte
///   connectors: []
/// ---
///
/// # Diagramme
///
/// ```mermaid
/// flowchart LR
///     shape-1["Mon texte"]
/// ```
/// ```
///
/// Toute évolution du schéma qui casserait la compatibilité (nouveau
/// champ obligatoire, changement de sens d'un champ existant...) doit
/// s'accompagner d'un incrément de [diagramFileFormatVersion] et d'une
/// logique de migration explicite dans [decodeDiagramDocument] : un
/// fichier dont la version ne correspond pas est aujourd'hui simplement
/// refusé (voir plus bas).
const int diagramFileFormatVersion = 1;

/// Sérialise [document] au format `.dgm.md` décrit ci-dessus.
String encodeDiagramDocument(DiagramDocument document) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('---');
  buffer.writeln('diagramme:');
  buffer.writeln('  version: $diagramFileFormatVersion');
  _writeShapes(buffer, document.shapes);
  _writeConnectors(buffer, document.connectors);
  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('# Diagramme');
  buffer.writeln();
  buffer.writeln('```mermaid');
  buffer.write(_mermaidFlowchart(document.shapes, document.connectors));
  buffer.writeln('```');

  return buffer.toString();
}

/// Désérialise un contenu `.dgm.md` (voir [encodeDiagramDocument]).
///
/// Ne lit QUE l'en-tête YAML : le bloc Mermaid, purement décoratif, est
/// ignoré.
///
/// Lève une [FormatException] si l'en-tête YAML est absent/mal formé, ou
/// si sa version ne correspond pas à [diagramFileFormatVersion].
({List<DiagramShape> shapes, List<DiagramConnector> connectors})
decodeDiagramDocument(String content) {
  final String frontmatter = _extractFrontmatter(content);

  final dynamic parsed = loadYaml(frontmatter);

  if (parsed is! Map || parsed['diagramme'] is! Map) {
    throw const FormatException(
      "Fichier .dgm.md invalide : clé racine 'diagramme' manquante dans "
      "l'en-tête YAML.",
    );
  }

  final Map diagramMap = parsed['diagramme'] as Map;

  final int version = (diagramMap['version'] as num?)?.toInt() ?? 0;

  if (version != diagramFileFormatVersion) {
    throw FormatException(
      'Version de fichier .dgm.md non supportée : $version (seule la '
      'version $diagramFileFormatVersion est prise en charge).',
    );
  }

  final List shapesYaml = (diagramMap['shapes'] as List?) ?? const [];
  final List connectorsYaml = (diagramMap['connectors'] as List?) ?? const [];

  final List<DiagramShape> shapes = [
    for (final dynamic entry in shapesYaml) _decodeShape(entry as Map),
  ];

  final List<DiagramConnector> connectors = [
    for (final dynamic entry in connectorsYaml) _decodeConnector(entry as Map),
  ];

  return (shapes: shapes, connectors: connectors);
}

/// Extrait le contenu situé entre les deux lignes `---` délimitant
/// l'en-tête YAML, sans le modifier (l'indentation et le contenu exacts
/// doivent être préservés pour que le parseur YAML les interprète
/// correctement).
String _extractFrontmatter(String content) {
  final List<String> lines = content.split('\n');

  if (lines.isEmpty || !_isFrontmatterDelimiter(lines.first)) {
    throw const FormatException(
      "Fichier .dgm.md invalide : il doit commencer par un en-tête YAML "
      "délimité par '---'.",
    );
  }

  final int endIndex = lines.indexWhere(_isFrontmatterDelimiter, 1);

  if (endIndex == -1) {
    throw const FormatException(
      "Fichier .dgm.md invalide : en-tête YAML non terminé (second '---' "
      'manquant).',
    );
  }

  return lines.sublist(1, endIndex).join('\n');
}

/// Un vrai délimiteur de frontmatter doit être EXACTEMENT `---`, sans
/// aucune indentation (seul un `\r` final, pour les fins de ligne
/// Windows, est toléré).
///
/// Une simple comparaison sur la ligne "trimée" matcherait à tort une
/// ligne `---` indentée à l'intérieur d'un bloc littéral YAML (le texte
/// d'une forme pourrait très bien contenir une ligne "---"), ce qui
/// tronquerait l'en-tête au mauvais endroit.
bool _isFrontmatterDelimiter(String line) {
  final String withoutTrailingCr = line.endsWith('\r')
      ? line.substring(0, line.length - 1)
      : line;

  return withoutTrailingCr == '---';
}

DiagramShape _decodeShape(Map map) {
  final Map position = map['position'] as Map;
  final Map size = map['size'] as Map;

  return DiagramShape(
    id: map['id'] as String,
    type: ShapeType.values.byName(map['type'] as String),
    position: Offset(
      (position['x'] as num).toDouble(),
      (position['y'] as num).toDouble(),
    ),
    width: (size['width'] as num).toDouble(),
    height: (size['height'] as num).toDouble(),
    text: (map['text'] as String?) ?? '',
    fillColor: _colorFromHex(map['fillColor'] as String),
    strokeColor: _colorFromHex(map['strokeColor'] as String),
  );
}

DiagramConnector _decodeConnector(Map map) {
  return DiagramConnector(
    id: map['id'] as String,
    fromShapeId: map['from'] as String,
    toShapeId: map['to'] as String,
  );
}

void _writeShapes(StringBuffer buffer, List<DiagramShape> shapes) {
  if (shapes.isEmpty) {
    buffer.writeln('  shapes: []');

    return;
  }

  buffer.writeln('  shapes:');

  for (final DiagramShape shape in shapes) {
    buffer.writeln('    - id: ${shape.id}');
    buffer.writeln('      type: ${shape.type.name}');
    buffer.writeln(
      '      position: {x: ${shape.position.dx}, y: ${shape.position.dy}}',
    );
    buffer.writeln(
      '      size: {width: ${shape.width}, height: ${shape.height}}',
    );
    buffer.writeln('      fillColor: "${_colorToHex(shape.fillColor)}"');
    buffer.writeln('      strokeColor: "${_colorToHex(shape.strokeColor)}"');
    _writeShapeText(buffer, shape.text);
  }
}

/// Écrit `text:` en bloc littéral YAML (`|2-`) : le texte reste lisible
/// tel quel, sans aucun caractère d'échappement, et réutilisable
/// directement dans un document Markdown ou LaTeX.
///
/// L'indicateur d'indentation explicite `2` (2 espaces de plus que la clé
/// `text:`) évite de dépendre de la détection automatique du parseur, qui
/// est ambiguë si la première ligne du texte est vide. L'indicateur de
/// troncature `-` (« strip ») garantit qu'aucun retour à la ligne n'est
/// ajouté au texte d'origine lors de la relecture.
void _writeShapeText(StringBuffer buffer, String text) {
  if (text.isEmpty) {
    buffer.writeln('      text: ""');

    return;
  }

  buffer.writeln('      text: |2-');

  for (final String line in text.split('\n')) {
    if (line.isEmpty) {
      buffer.writeln();
    } else {
      buffer.writeln('        $line');
    }
  }
}

void _writeConnectors(StringBuffer buffer, List<DiagramConnector> connectors) {
  if (connectors.isEmpty) {
    buffer.writeln('  connectors: []');

    return;
  }

  buffer.writeln('  connectors:');

  for (final DiagramConnector connector in connectors) {
    buffer.writeln('    - id: ${connector.id}');
    buffer.writeln('      from: ${connector.fromShapeId}');
    buffer.writeln('      to: ${connector.toShapeId}');
  }
}

/// Couleur -> `"#RRGGBB"` (l'application ne produit que des couleurs
/// opaques : le canal alpha n'est pas conservé).
String _colorToHex(Color color) {
  final int rgb = color.toARGB32() & 0xFFFFFF;

  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color _colorFromHex(String hex) {
  final String digits = hex.startsWith('#') ? hex.substring(1) : hex;

  return Color(0xFF000000 | int.parse(digits, radix: 16));
}

/// Représentation Mermaid (`flowchart`) du diagramme, purement pour
/// l'affichage dans un lecteur Markdown : voir la documentation en tête
/// de fichier.
String _mermaidFlowchart(
  List<DiagramShape> shapes,
  List<DiagramConnector> connectors,
) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('flowchart LR');

  for (final DiagramShape shape in shapes) {
    buffer.writeln(_mermaidNode(shape));
  }

  for (final DiagramConnector connector in connectors) {
    buffer.writeln('    ${connector.fromShapeId} --> ${connector.toShapeId}');
  }

  return buffer.toString();
}

String _mermaidNode(DiagramShape shape) {
  final String label = _mermaidLabel(shape);

  switch (shape.type) {
    case ShapeType.rectangle:
      return '    ${shape.id}["$label"]';
    case ShapeType.circle:
      return '    ${shape.id}(("$label"))';
  }
}

/// Texte affiché sur un noeud Mermaid : l'identifiant de la forme sert de
/// repli si elle n'a pas de texte, les retours à la ligne deviennent
/// `<br/>` (syntaxe Mermaid), et les guillemets doubles — qui
/// termineraient prématurément le label — sont remplacés par des
/// guillemets simples.
String _mermaidLabel(DiagramShape shape) {
  final String raw = shape.text.trim().isEmpty ? shape.id : shape.text;

  return raw.replaceAll('\n', '<br/>').replaceAll('"', "'");
}
