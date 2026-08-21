import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diagramme/main.dart';

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
}