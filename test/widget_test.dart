import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/main.dart';
import 'package:diagramme/widgets/diagram_canvas.dart';
void main() {
  testWidgets(
    'Application starts and displays the diagram canvas',
    (WidgetTester tester) async {
      // ------------------------------------------------------------
      // ARRANGE / ACT
      // ------------------------------------------------------------
      //
      // On démarre notre application exactement comme Flutter
      // le ferait normalement.
      //
      // pumpWidget() construit l'arbre des widgets et affiche
      // sa première frame.
      await tester.pumpWidget(const DiagrammeApp());

      // ------------------------------------------------------------
      // ASSERT
      // ------------------------------------------------------------
      //
      // Notre application doit contenir un GridCanvas.
      //
      // Si quelqu'un casse un jour l'écran principal et supprime
      // accidentellement le canevas, ce test échouera.
      expect(
        find.byType(GridCanvas),
        findsOneWidget,
      );

      // Notre canevas utilise un CustomPaint pour dessiner :
      // - la grille
      // - les formes
      // - l'origine
      //
      // On vérifie donc qu'au moins un CustomPaint existe.
      expect(
        find.byType(CustomPaint),
        findsWidgets,
      );

      // Au démarrage, notre zoom vaut 100 %.
      //
      // L'indicateur doit donc afficher "100 %".
      expect(
        find.text('100 %'),
        findsOneWidget,
      );
    },

  );
  testWidgets(
  'Rectangle tool creates a rectangle',
  (WidgetTester tester) async {
    // ------------------------------------------------------------
    // ARRANGE
    // ------------------------------------------------------------
    // Démarrage de l'application.
    await tester.pumpWidget(const DiagrammeApp());

    // On vérifie que le bouton Rectangle existe.
    final rectangleButton = find.byTooltip('Rectangle');

    expect(
      rectangleButton,
      findsOneWidget,
    );

    // ------------------------------------------------------------
    // ACT
    // ------------------------------------------------------------
    //
    // On simule un clic utilisateur sur le bouton Rectangle.
    await tester.tap(rectangleButton);
    await tester.pump();

    // Puis un clic au milieu du canevas.
    //
    // tapAt() utilise des coordonnées écran, exactement comme
    // notre vrai clic de souris.
    await tester.tapAt(
      const Offset(400, 300),
    );

    // On laisse Flutter reconstruire l'affichage.
    await tester.pump();

    // ------------------------------------------------------------
    // ASSERT
    // ------------------------------------------------------------
    //
    // Notre modèle n'est actuellement pas directement exposé
    // au test.
    //
    // En revanche, après création, l'outil doit automatiquement
    // revenir au mode normal.
    //
    // Pour l'instant ce test valide surtout toute la chaîne :
    //
    // bouton -> geste -> création -> reconstruction
    //
    // et vérifie qu'aucune exception Flutter n'a été produite.
    expect(
      tester.takeException(),
      isNull,
    );
  },
);

  testWidgets(
  'Circle tool creates a circle',
  (WidgetTester tester) async {
    await tester.pumpWidget(const DiagrammeApp());

    // Le bouton Cercle doit exister.
    final circleButton = find.byTooltip('Cercle');

    expect(
      circleButton,
      findsOneWidget,
    );

    // Activation de l'outil.
    await tester.tap(circleButton);
    await tester.pump();

    // Création du cercle.
    await tester.tapAt(
      const Offset(400, 300),
    );
    await tester.pump();

    // Aucune exception ne doit avoir eu lieu.
    expect(
      tester.takeException(),
      isNull,
    );
  },
);
  testWidgets(
  'Selection tool is available',
  (WidgetTester tester) async {
    await tester.pumpWidget(const DiagrammeApp());

    expect(
      find.byTooltip('Sélection'),
      findsOneWidget,
    );
  },
);

  testWidgets(
  'Connector tool can connect two shapes',
  (WidgetTester tester) async {
    await tester.pumpWidget(const DiagrammeApp());

    // ------------------------------------------------------------
    // 1. Créer un rectangle
    // ------------------------------------------------------------
    await tester.tap(
      find.byTooltip('Rectangle'),
    );
    await tester.pump();

    await tester.tapAt(
      const Offset(300, 250),
    );
    await tester.pump();

    // ------------------------------------------------------------
    // 2. Créer un cercle
    // ------------------------------------------------------------
    await tester.tap(
      find.byTooltip('Cercle'),
    );
    await tester.pump();

    await tester.tapAt(
      const Offset(600, 250),
    );
    await tester.pump();

    // ------------------------------------------------------------
    // 3. Activer l'outil connecteur
    // ------------------------------------------------------------
    await tester.tap(
      find.byTooltip('Connecteur'),
    );
    await tester.pump();

    // ------------------------------------------------------------
    // 4. Cliquer sur les deux formes
    // ------------------------------------------------------------
    //
    // Les positions choisies sont volontairement au centre
    // approximatif des formes créées plus haut.
    await tester.tapAt(
      const Offset(350, 300),
    );
    await tester.pump();

    await tester.tapAt(
      const Offset(660, 310),
    );
    await tester.pump();

    // ------------------------------------------------------------
    // ASSERT
    // ------------------------------------------------------------
    //
    // Pour l'instant, l'état du diagramme n'est pas encore
    // exposé directement aux tests.
    //
    // On valide donc que toute la séquence utilisateur complète
    // s'exécute sans exception.
    expect(
      tester.takeException(),
      isNull,
    );
  },
);

  testWidgets(
  'Pinch gesture changes canvas zoom',
  (WidgetTester tester) async {
    // ------------------------------------------------------------
    // ARRANGE
    // ------------------------------------------------------------
    await tester.pumpWidget(const DiagrammeApp());

    // Au démarrage, le zoom doit être à 100 %.
    expect(
      find.text('100 %'),
      findsOneWidget,
    );

    // ------------------------------------------------------------
    // ACT
    // ------------------------------------------------------------
    //
    // On crée deux pointeurs tactiles.
    //
    // Ils commencent assez proches l'un de l'autre...
    final firstFinger = await tester.startGesture(
      const Offset(350, 300),
      pointer: 1,
    );

    final secondFinger = await tester.startGesture(
      const Offset(450, 300),
      pointer: 2,
    );

    await tester.pump();

    // ...puis on les éloigne.
    //
    // C'est l'équivalent d'un pinch-out :
    // donc un zoom avant.
    await firstFinger.moveTo(
      const Offset(300, 300),
    );

    await secondFinger.moveTo(
      const Offset(500, 300),
    );

    await tester.pump();

    // On relâche les deux doigts.
    await firstFinger.up();
    await secondFinger.up();

    await tester.pump();

    // ------------------------------------------------------------
    // ASSERT
    // ------------------------------------------------------------
    //
    // Le zoom ne doit plus être exactement à 100 %.
    expect(
      find.text('100 %'),
      findsNothing,
    );

    // Et aucune exception Flutter ne doit avoir eu lieu.
    expect(
      tester.takeException(),
      isNull,
    );
  },
);

}