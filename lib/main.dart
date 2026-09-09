import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:diagramme/widgets/diagram_canvas.dart';

void main() {
  runApp(const DiagrammeApp());
}

class DiagrammeApp extends StatelessWidget {
  const DiagrammeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: const GridCanvas(),
        // bottom-left : l'indicateur de zoom occupe déjà le bas-droite
        // du canevas (voir ZoomIndicator dans diagram_canvas.dart).
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.small(
              tooltip: 'Documentation utilisateur',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const UserDocumentationPage(),
                  ),
                );
              },
              child: const Icon(Icons.help_outline),
            );
          },
        ),
      ),
    );
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
