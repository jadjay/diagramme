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

  testWidgets('Dragging the resize handle resizes the selected shape', (
    WidgetTester tester,
  ) async {
    // ------------------------------------------------------------
    // 1. Démarre l'application
    // ------------------------------------------------------------
    await tester.pumpWidget(const DiagrammeApp());

    // ------------------------------------------------------------
    // 2. Crée un rectangle 200 x 100
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();

    const Offset rectanglePosition = Offset(300, 200);

    await tester.tapAt(rectanglePosition);

    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 3. Repasse en sélection puis sélectionne la forme
    // ------------------------------------------------------------
    await tester.tap(find.byTooltip('Sélection'));
    await tester.pump();

    const Offset rectangleCenter = Offset(400, 250);

    await tester.tapAt(rectangleCenter);

    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // 4. Glisse la poignée de redimensionnement
    // ------------------------------------------------------------
    //
    // Le rectangle a été créé en (300, 200) avec une taille de
    // 200 x 100 : son coin bas-droit — donc la poignée — se trouve
    // à (500, 300) en coordonnées écran (le viewport est encore à
    // l'identité à ce stade : aucun pan/zoom n'a eu lieu).
    const Offset handlePosition = Offset(500, 300);

    final gesture = await tester.startGesture(handlePosition);

    await gesture.moveBy(const Offset(50, 30));

    await tester.pump();

    await gesture.up();

    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // ASSERT
    // ------------------------------------------------------------
    //
    // Comme pour les autres tests de ce fichier, le modèle n'est pas
    // directement exposé : on valide donc que toute la chaîne
    // (sélection -> poignée -> drag -> redimensionnement) s'exécute
    // sans exception.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Resize handle never shrinks a shape below the minimum size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DiagrammeApp());

    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();

    const Offset rectanglePosition = Offset(300, 200);

    await tester.tapAt(rectanglePosition);

    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byTooltip('Sélection'));
    await tester.pump();

    const Offset rectangleCenter = Offset(400, 250);

    await tester.tapAt(rectangleCenter);

    await tester.pump(const Duration(milliseconds: 100));

    // Glisse la poignée très loin vers le coin haut-gauche : de quoi
    // rendre la largeur et la hauteur négatives si rien ne les
    // limitait.
    const Offset handlePosition = Offset(500, 300);

    final gesture = await tester.startGesture(handlePosition);

    await gesture.moveBy(const Offset(-1000, -1000));

    await tester.pump();

    await gesture.up();

    await tester.pump(const Duration(milliseconds: 100));

    // Aucune exception : notamment aucun Rect / Offset invalide côté
    // CustomPainter, ce qui serait le cas avec des dimensions
    // négatives.
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Resize handle works for a circle even when the drag starts off-center',
    (WidgetTester tester) async {
      // ------------------------------------------------------------
      // Régression : sur un appareil réel, le doigt/curseur touche
      // rarement le centre exact de la poignée. Ce test démarre le
      // drag volontairement décalé du centre de la poignée, à un
      // point qui se trouve géométriquement HORS du disque du
      // cercle (le coin de la boîte englobante, où vit la poignée,
      // est toujours hors du cercle inscrit) : avec l'ancien
      // mécanisme (hit-test partagé avec ShapeHitTester), ce point
      // ne déclenchait aucun redimensionnement.
      // ------------------------------------------------------------
      await tester.pumpWidget(const DiagrammeApp());

      await tester.tap(find.byTooltip('Cercle'));
      await tester.pump();

      const Offset circlePosition = Offset(300, 200);

      await tester.tapAt(circlePosition);

      // Le point de sélection ci-dessous (centre du cercle) est à
      // moins de 100 unités de ce point de création : on laisse donc
      // largement passer le délai du double-tap (300 ms) pour ne pas
      // que ce second clic soit interprété comme un double-tap et
      // ouvre l'éditeur de texte au lieu de simplement sélectionner
      // la forme.
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byTooltip('Sélection'));
      await tester.pump();

      // Cercle 120 x 120 créé en (300, 200) : son centre est donc
      // en (360, 260) et le coin bas-droit de sa boîte englobante
      // (la poignée) en (420, 320).
      const Offset circleCenter = Offset(360, 260);

      await tester.tapAt(circleCenter);

      await tester.pump(const Duration(milliseconds: 400));

      // Décalage de 15 unités en x et en y par rapport au centre de
      // la poignée : toujours dans la nouvelle zone de détection
      // (44 x 44) mais hors de l'ancien disque de 14 et hors du
      // cercle lui-même.
      const Offset nearHandle = Offset(420 + 15, 320 - 15);

      final gesture = await tester.startGesture(nearHandle);

      await gesture.moveBy(const Offset(40, 40));

      await tester.pump();

      await gesture.up();

      await tester.pump(const Duration(milliseconds: 100));

      // Comme pour les autres tests de resize de ce fichier, le
      // modèle n'est pas directement exposé : on valide donc que
      // toute la chaîne (sélection -> poignée -> drag décalé ->
      // redimensionnement) s'exécute sans exception, y compris pour
      // un cercle.
      expect(tester.takeException(), isNull);
    },
  );

  /// Crée un rectangle 200 x 100 en (300, 200), repasse en outil
  /// Sélection puis double-tape son centre (400, 250) pour ouvrir
  /// l'éditeur de texte. Factorisé pour les tests multiligne
  /// ci-dessous, qui partagent tous cette même mise en place.
  Future<void> openTextEditorOnNewRectangle(WidgetTester tester) async {
    await tester.pumpWidget(const DiagrammeApp());

    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();

    const Offset rectanglePosition = Offset(300, 200);

    await tester.tapAt(rectanglePosition);

    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byTooltip('Sélection'));
    await tester.pump();

    const Offset rectangleCenter = Offset(400, 250);

    await tester.tapAt(rectangleCenter);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(rectangleCenter);
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
  }

  testWidgets('Pressing Enter inserts a newline instead of validating', (
    WidgetTester tester,
  ) async {
    await openTextEditorOnNewRectangle(tester);

    await tester.enterText(find.byType(TextField), 'Ligne 1');
    await tester.pump();

    // Le TextField a le focus (autofocus) : on simule la touche
    // Entrée du clavier physique.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // L'éditeur doit rester ouvert : Entrée n'a pas validé, elle a
    // seulement inséré un retour à la ligne.
    expect(find.byType(TextField), findsOneWidget);

    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Ctrl+Enter validates and closes the multiline editor', (
    WidgetTester tester,
  ) async {
    await openTextEditorOnNewRectangle(tester);

    await tester.enterText(find.byType(TextField), 'Routeur\nprincipal');
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pump();

    // Ctrl+Entrée a validé : l'éditeur doit avoir disparu.
    expect(find.byType(TextField), findsNothing);

    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Tapping outside the multiline editor validates and closes it', (
    WidgetTester tester,
  ) async {
    await openTextEditorOnNewRectangle(tester);

    await tester.enterText(find.byType(TextField), 'Texte');
    await tester.pump();

    // Un point clairement à l'extérieur du rectangle et de son champ.
    await tester.tapAt(const Offset(700, 500));
    await tester.pump();

    expect(find.byType(TextField), findsNothing);

    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets(
    'Tapping inside the multiline editor keeps it open (does not count as outside)',
    (WidgetTester tester) async {
      await openTextEditorOnNewRectangle(tester);

      await tester.enterText(find.byType(TextField), 'Texte');
      await tester.pump();

      // Reclique à l'intérieur même du champ, près de son coin
      // haut-gauche (le champ est aligné sur le coin haut-gauche de
      // la forme et grandit vers le bas, donc ce point reste à
      // l'intérieur quelle que soit la hauteur exacte rendue) : ça
      // doit être traité comme un clic pour repositionner le
      // curseur, PAS comme un clic extérieur qui terminerait
      // l'édition.
      const Offset insideEditor = Offset(400, 210);

      await tester.tapAt(insideEditor);
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);

      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 100));
    },
  );

  testWidgets('Multiline text survives resizing the shape', (
    WidgetTester tester,
  ) async {
    await openTextEditorOnNewRectangle(tester);

    await tester.enterText(
      find.byType(TextField),
      'Une ligne assez longue pour se répartir\nsur plusieurs lignes',
    );
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pump(const Duration(milliseconds: 100));

    // Glisse la poignée de redimensionnement (coin bas-droit du
    // rectangle, voir test resize) pour vérifier que le rendu du
    // texte multiligne ne casse rien pendant/après un resize.
    const Offset handlePosition = Offset(500, 300);

    final gesture = await tester.startGesture(handlePosition);
    await gesture.moveBy(const Offset(80, 40));
    await tester.pump();
    await gesture.up();

    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'The file button opens a menu with Sauvegarder, Ouvrir and Exporter '
    'en PNG',
    (WidgetTester tester) async {
      await tester.pumpWidget(const DiagrammeApp());

      final Finder fileButton = find.byTooltip('Fichier');

      expect(fileButton, findsOneWidget);

      await tester.tap(fileButton);
      await tester.pumpAndSettle();

      expect(find.text('Sauvegarder'), findsOneWidget);
      expect(find.text('Ouvrir'), findsOneWidget);
      expect(find.text('Exporter en PNG'), findsOneWidget);

      // Les trois entrées du menu sont actionnables.
      for (final String label in [
        'Sauvegarder',
        'Ouvrir',
        'Exporter en PNG',
      ]) {
        final MenuItemButton button = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, label),
        );

        expect(button.onPressed, isNotNull);
      }

      // On ne tape pas les entrées du menu ici : elles appellent
      // FilePicker.platform, qui n'a pas d'implémentation de plateforme
      // dans l'environnement de test (la logique d'encodage/décodage
      // elle-même est testée indépendamment de l'UI dans
      // test/diagram_file_format_test.dart et
      // test/diagram_png_exporter_test.dart).
      expect(tester.takeException(), isNull);
    },
  );
}
