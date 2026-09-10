import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:diagramme/widgets/diagram_canvas.dart';

void main() {
  runApp(const DiagrammeApp());
}

class DiagrammeApp extends StatelessWidget {
  const DiagrammeApp({super.key});

  /// Permet d'atteindre [GridCanvasState] (export/import du document)
  /// depuis les boutons Sauvegarder/Ouvrir ci-dessous, qui vivent en
  /// dehors de `GridCanvas` (dans le `Scaffold` qui l'englobe).
  ///
  /// `static` : l'application ne crée qu'une seule instance de
  /// `DiagrammeApp`, donc pas de risque de collision entre plusieurs
  /// clés — et cela évite de convertir ce widget en StatefulWidget
  /// uniquement pour porter cette clé.
  static final GlobalKey<GridCanvasState> _canvasKey =
      GlobalKey<GridCanvasState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GridCanvas(key: _canvasKey),
        // bottom-left : l'indicateur de zoom occupe déjà le bas-droite
        // du canevas (voir ZoomIndicator dans diagram_canvas.dart).
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Builder(
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MenuAnchor(
                  builder:
                      (
                        BuildContext context,
                        MenuController controller,
                        Widget? child,
                      ) {
                        return FloatingActionButton.small(
                          heroTag: 'file-menu-fab',
                          tooltip: 'Fichier',
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          child: const Icon(Icons.folder_outlined),
                        );
                      },
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.save_outlined),
                      onPressed: () => _saveDiagram(context, _canvasKey),
                      child: const Text('Sauvegarder'),
                    ),
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.folder_open_outlined),
                      onPressed: () => _openDiagram(context, _canvasKey),
                      child: const Text('Ouvrir'),
                    ),
                    // Prévu pour plus tard (export vers un autre format
                    // que .dgm.md, par exemple une image) : le bouton
                    // reste visible mais désactivé (onPressed: null) en
                    // attendant.
                    const MenuItemButton(
                      leadingIcon: Icon(Icons.ios_share_outlined),
                      onPressed: null,
                      child: Text('Exporter (bientôt)'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                FloatingActionButton.small(
                  heroTag: 'help-fab',
                  tooltip: 'Documentation utilisateur',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const UserDocumentationPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.help_outline),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Sauvegarde le diagramme actuel dans un fichier `.dgm.md` choisi par
/// l'utilisateur.
Future<void> _saveDiagram(
  BuildContext context,
  GlobalKey<GridCanvasState> canvasKey,
) async {
  final GridCanvasState? canvas = canvasKey.currentState;

  if (canvas == null) {
    return;
  }

  final String content = canvas.exportDocument();

  final String? path = await FilePicker.platform.saveFile(
    dialogTitle: 'Sauvegarder le diagramme',
    fileName: 'diagramme.dgm.md',
    type: FileType.custom,
    allowedExtensions: ['md'],
    bytes: Uint8List.fromList(utf8.encode(content)),
  );

  if (path == null) {
    // Sélection annulée par l'utilisateur.
    return;
  }

  // Sur Android, file_picker écrit déjà le fichier lui-même à partir de
  // `bytes` (le Storage Access Framework ne donne pas accès à un chemin
  // de fichier classique) ; sur Linux desktop, saveFile() se contente de
  // choisir l'emplacement et c'est à nous d'écrire le contenu.
  if (!Platform.isAndroid) {
    await File(path).writeAsString(content);
  }

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Diagramme sauvegardé.')));
  }
}

/// Ouvre un fichier `.dgm.md` choisi par l'utilisateur et remplace le
/// diagramme actuel par son contenu.
Future<void> _openDiagram(
  BuildContext context,
  GlobalKey<GridCanvasState> canvasKey,
) async {
  final GridCanvasState? canvas = canvasKey.currentState;

  if (canvas == null) {
    return;
  }

  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Ouvrir un diagramme',
    type: FileType.custom,
    allowedExtensions: ['md'],
    // Demande le contenu directement (plutôt qu'un chemin de fichier),
    // pour fonctionner de façon uniforme sur toutes les plateformes —
    // sur Android notamment, le chemin renvoyé par le Storage Access
    // Framework n'est pas toujours utilisable directement avec File().
    withData: true,
  );

  if (result == null) {
    // Sélection annulée par l'utilisateur.
    return;
  }

  final Uint8List? bytes = result.files.single.bytes;

  if (bytes == null) {
    return;
  }

  try {
    canvas.importDocument(utf8.decode(bytes));

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Diagramme chargé.')));
    }
  } on FormatException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier invalide : ${error.message}')),
      );
    }
  }
}

class UserDocumentationPage extends StatelessWidget {
  const UserDocumentationPage({super.key});

  Future<String> _loadDocumentation() {
    return rootBundle.loadString('USERDOC.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentation')),
      body: FutureBuilder<String>(
        future: _loadDocumentation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('Impossible de charger la documentation.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SelectableText(snapshot.data!),
          );
        },
      ),
    );
  }
}
