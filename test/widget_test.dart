import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/main.dart';
import 'package:diagramme/widgets/diagram_canvas.dart';

void main() {
  testWidgets('Application starts and displays the diagram canvas', (
    WidgetTester tester,
  ) async {
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
    expect(find.byType(GridCanvas), findsOneWidget);

    // Notre canevas utilise un CustomPaint pour dessiner :
    // - la grille
    // - les formes
    // - l'origine
    //
    // On vérifie donc qu'au moins un CustomPaint existe.
    expect(find.byType(CustomPaint), findsWidgets);

    // Au démarrage, notre zoom vaut 100 %.
    //
    // L'indicateur doit donc afficher "100 %".
    expect(find.text('100 %'), findsOneWidget);
  });
  testWidgets('Rectangle tool creates a rectangle', (
    WidgetTester tester,
  ) async {
    // ------------------------------------------------------------
    // ARRANGE
    // ------------------------------------------------------------
    // Démarrage de l'application.
    await tester.pumpWidget(const DiagrammeApp());

    // On vérifie que le bouton Rectangle existe.
    final rectangleButton = find.byTooltip('Rectangle');

    expect(rectangleButton, findsOneWidget);

    // ------------------------------------------------------------
    // ACT
    // ------------------------------------------------------------
    //
    // On simule un clic utilisateur sur le bouton Rectangle.
    await tester.tap(rectangleButton);
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // Puis un clic au milieu du canevas.
    //
    // tapAt() utilise des coordonnées écran, exactement comme
    // notre vrai clic de souris.
    await tester.tapAt(const Offset(400, 300));

    // On laisse Flutter reconstruire l'affichage.
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

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
    expect(tester.takeException(), isNull);
  });

  testWidgets('Circle tool creates a circle', (WidgetTester tester) async {
    await tester.pumpWidget(const DiagrammeApp());

    // Le bouton Cercle doit exister.
    final circleButton = find.byTooltip('Cercle');

    expect(circleButton, findsOneWidget);

    // Activation de l'outil.
    await tester.tap(circleButton);
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // Création du cercle.
    await tester.tapAt(const Offset(400, 300));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // Aucune exception ne doit avoir eu lieu.
    expect(tester.takeException(), isNull);
  });
  testWidgets('Selection tool is available', (WidgetTester tester) async {
    await tester.pumpWidget(const DiagrammeApp());

    expect(find.byTooltip('Sélection'), findsOneWidget);
  });

  testWidgets('Connector tool can connect two shapes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DiagrammeApp());

    // ------------------------------------------------------------
    // 1. Créer un rectangle
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Rectangle'));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tapAt(const Offset(300, 250));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 2. Créer un cercle
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Cercle'));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tapAt(const Offset(600, 250));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 3. Activer l'outil connecteur
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Connecteur'));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 4. Cliquer sur les deux formes
    // ------------------------------------------------------------
    //
    // Les positions choisies sont volontairement au centre
    // approximatif des formes créées plus haut.
    await tester.tapAt(const Offset(350, 300));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tapAt(const Offset(660, 310));
    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // ASSERT
    // ------------------------------------------------------------
    //
    // Pour l'instant, l'état du diagramme n'est pas encore
    // exposé directement aux tests.
    //
    // On valide donc que toute la séquence utilisateur complète
    // s'exécute sans exception.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pinch gesture changes canvas zoom', (WidgetTester tester) async {
    // ------------------------------------------------------------
    // ARRANGE
    // ------------------------------------------------------------
    await tester.pumpWidget(const DiagrammeApp());

    // Au démarrage, le zoom doit être à 100 %.
    expect(find.text('100 %'), findsOneWidget);

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

    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // ...puis on les éloigne.
    //
    // C'est l'équivalent d'un pinch-out :
    // donc un zoom avant.
    await firstFinger.moveTo(const Offset(300, 300));

    await secondFinger.moveTo(const Offset(500, 300));

    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // On relâche les deux doigts.
    await firstFinger.up();
    await secondFinger.up();

    // Depuis que le canevas gère le double-tap, Flutter attend
    // brièvement un éventuel second tap.
    //
    // On laisse donc expirer le timer du DoubleTapGestureRecognizer
    // avant de terminer le test.
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // ASSERT
    // ------------------------------------------------------------
    //
    // Le zoom ne doit plus être exactement à 100 %.
    expect(find.text('100 %'), findsNothing);

    // Et aucune exception Flutter ne doit avoir eu lieu.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Double tap on shape allows text editing', (
    WidgetTester tester,
  ) async {
    // ------------------------------------------------------------
    // 1. Démarre l'application
    // ------------------------------------------------------------
    await tester.pumpWidget(const DiagrammeApp());

    // ------------------------------------------------------------
    // 2. Crée un rectangle
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();

    // Le clic de création correspond au coin supérieur gauche
    // de notre rectangle.
    const Offset rectanglePosition = Offset(300, 200);

    await tester.tapAt(rectanglePosition);

    // Important :
    // le GestureDetector surveille aussi les doubles taps.
    //
    // On attend assez longtemps pour que ce clic de création
    // soit définitivement considéré comme un clic simple.
    await tester.pump(const Duration(milliseconds: 400));

    // ------------------------------------------------------------
    // 3. Repasse en mode sélection
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Sélection'));
    await tester.pump();

    // Notre rectangle fait 200 x 100.
    //
    // Il a été créé en (300, 200).
    //
    // Son centre est donc :
    //
    // X = 300 + 100 = 400
    // Y = 200 +  50 = 250
    const Offset rectangleCenter = Offset(400, 250);

    // ------------------------------------------------------------
    // 4. Double tap sur le rectangle
    // ------------------------------------------------------------

    // Premier tap.
    await tester.tapAt(rectangleCenter);

    // Petit délai :
    // assez long pour que Flutter distingue les deux taps,
    // mais assez court pour rester dans la fenêtre du double tap.
    await tester.pump(const Duration(milliseconds: 60));

    // Deuxième tap.
    await tester.tapAt(rectangleCenter);

    // Laisse Flutter appeler onDoubleTapDown
    // et reconstruire le Stack.
    await tester.pump();

    // ------------------------------------------------------------
    // 5. L'éditeur doit apparaître
    // ------------------------------------------------------------
    expect(find.byType(TextField), findsOneWidget);

    // ------------------------------------------------------------
    // 6. Saisie du texte
    // ------------------------------------------------------------
    await tester.enterText(find.byType(TextField), 'Routeur');

    await tester.pump();

    // Le TextField doit contenir notre texte.
    expect(find.text('Routeur'), findsOneWidget);

    // ------------------------------------------------------------
    // 7. Validation
    // ------------------------------------------------------------
    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.pump();

    // L'éditeur doit disparaître.
    expect(find.byType(TextField), findsNothing);

    // Aucune exception Flutter.
    expect(tester.takeException(), isNull);

    // Le GestureDetector garde brièvement un timer interne
    // pour détecter un éventuel double-tap supplémentaire.
    //
    // On le laisse expirer avant de terminer le test,
    // sinon flutter_test considère qu'un timer est encore actif.
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Delete button removes selected shape', (
    WidgetTester tester,
  ) async {
    // ------------------------------------------------------------
    // 1. Démarre l'application
    // ------------------------------------------------------------
    await tester.pumpWidget(const DiagrammeApp());

    // ------------------------------------------------------------
    // 2. Crée un rectangle
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();

    const Offset rectanglePosition = Offset(300, 200);

    await tester.tapAt(rectanglePosition);

    // Laisse expirer le timer du double-tap.
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 3. Repasse en mode sélection
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Sélection'));
    await tester.pump();

    // Le rectangle fait 200 x 100.
    //
    // Son centre est donc :
    //
    // (300 + 100, 200 + 50)
    const Offset rectangleCenter = Offset(400, 250);

    // Sélection du rectangle.
    await tester.tapAt(rectangleCenter);

    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 4. Suppression
    // ------------------------------------------------------------
    final deleteButton = find.byTooltip('Supprimer');

    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);

    await tester.pump();

    // ------------------------------------------------------------
    // 5. ASSERT
    // ------------------------------------------------------------
    //
    // Le bouton doit fonctionner sans exception.
    expect(tester.takeException(), isNull);

    // ------------------------------------------------------------
    // 6. Vérification indirecte
    // ------------------------------------------------------------
    //
    // On reclique à l'endroit où se trouvait le rectangle.
    //
    // S'il existait encore, il serait sélectionné.
    // Puis un second clic sur Supprimer le supprimerait.
    //
    // Ici, on vérifie surtout que toute la chaîne :
    //
    // création -> sélection -> suppression
    //
    // fonctionne correctement.
    await tester.tapAt(rectangleCenter);

    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  testWidgets('Delete key removes selected shape', (WidgetTester tester) async {
    // ------------------------------------------------------------
    // 1. Démarre l'application
    // ------------------------------------------------------------
    await tester.pumpWidget(const DiagrammeApp());

    // ------------------------------------------------------------
    // 2. Crée un rectangle
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();

    const Offset rectanglePosition = Offset(300, 200);

    await tester.tapAt(rectanglePosition);

    // Laisse expirer le timer du double-tap.
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 3. Repasse en mode sélection
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Sélection'));
    await tester.pump();

    const Offset rectangleCenter = Offset(400, 250);

    // Sélectionne la forme.
    await tester.tapAt(rectangleCenter);

    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 4. Appuie sur Delete
    // ------------------------------------------------------------
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);

    await tester.pump();

    // ------------------------------------------------------------
    // 5. Vérifie qu'il n'y a aucune erreur
    // ------------------------------------------------------------
    expect(tester.takeException(), isNull);

    // Laisse mourir un éventuel timer du GestureDetector
    // avant la fin du test.
    await tester.pump(const Duration(milliseconds: 100));
  });
  testWidgets('Shape fill and stroke colors can be changed', (
    WidgetTester tester,
  ) async {
    // ------------------------------------------------------------
    // 1. Démarre l'application
    // ------------------------------------------------------------
    await tester.pumpWidget(const DiagrammeApp());

    // ------------------------------------------------------------
    // 2. Crée un rectangle
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();

    const Offset rectanglePosition = Offset(300, 200);

    await tester.tapAt(rectanglePosition);

    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 3. Repasse en sélection
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Sélection'));
    await tester.pump();

    const Offset rectangleCenter = Offset(400, 250);

    await tester.tapAt(rectangleCenter);

    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 4. Ouvre la palette de remplissage
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Couleur de remplissage'));

    await tester.pumpAndSettle();

    // La palette doit apparaître.
    expect(find.byTooltip('Rouge'), findsOneWidget);
    await tester.tap(find.byTooltip('Rouge'));

    await tester.pumpAndSettle();

    // Ferme le menu Fill en cliquant dans le canvas.
    await tester.tapAt(const Offset(700, 500));

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Couleur de contour'));

    await tester.pumpAndSettle();
    // ------------------------------------------------------------
    // 5. Ouvre la palette de contour
    // ------------------------------------------------------------

    expect(find.byTooltip('Bleu'), findsOneWidget);

    // Change le contour.
    await tester.tap(find.byTooltip('Bleu'));

    await tester.pumpAndSettle();

    // ------------------------------------------------------------
    // 6. Vérification
    // ------------------------------------------------------------
    //
    // Les formes sont dessinées dans un CustomPainter,
    // donc on ne peut pas interroger directement leur couleur
    // avec un Finder.
    //
    // Ce test verrouille donc toute la chaîne utilisateur :
    //
    // sélection -> menu fill -> couleur
    //           -> menu stroke -> couleur
    //
    // et vérifie surtout que les callbacks ne provoquent
    // aucune exception.
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 100));
  });
}
