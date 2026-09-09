# TODO — feuille de route

Ce document regroupe les prochaines étapes envisagées pour **Diagramme**.

## Convention de travail

Pour chaque PR fonctionnelle :

- la fonctionnalité travaillée est marquée `[WIP]` dans ce fichier ;
- juste avant le merge, `[WIP]` est retiré et la tâche est cochée `[x]` ;
- le tag de version est posé sur le commit de merge ;
- la GitHub Release est générée à partir de ce tag.

La vision à moyen terme est détaillée dans `ROADMAP.md`.

## Documentation utilisateur

- [x] Créer `USERDOC.md`.
- [x] Rendre `USERDOC.md` accessible depuis l'application via un bouton d'aide.
- [x] Créer `ROADMAP.md` et formaliser le workflow PR / merge / tag / release.

## Nettoyage (Phase 1 de la roadmap)

- [x] Refaire le `README.md` pour présenter réellement le projet.
- [x] Supprimer `lib/main.dart_Old`.
- [x] Supprimer les blocs de formes/connecteurs de test commentés dans `diagram_canvas.dart`.
- [x] Supprimer les callbacks et `debugPrint` commentés devenus morts dans `diagram_canvas.dart`.

## Refactorisation du cœur (Phase 2 de la roadmap)

- [x] Extraire l'état du document (formes, connecteurs, sélection) hors
      de `GridCanvas` vers `DiagramDocument`.
- [x] Extraire la logique de sélection et de hit-testing vers `ShapeHitTester`,
      avec tests unitaires (`test/shape_hit_tester_test.dart`).
- [x] Extraire la logique pan / zoom / transformation du canevas vers
      `CanvasViewport`, avec tests unitaires (`test/canvas_viewport_test.dart`).
- [x] Extraire le champ de texte superposé vers `ShapeTextEditor`
      (widget autonome, sans état). `diagram_canvas.dart` : 1019 → 526 lignes.

## Resize des formes

- [ ] Ajouter une seule poignée de redimensionnement en bas à droite de la forme sélectionnée.
- [ ] Utiliser le même principe pour les rectangles et les cercles.
- [ ] Gérer le drag de la poignée pour modifier `width` et `height`.
- [ ] Définir une taille minimale afin d'éviter les formes trop petites ou les dimensions négatives.
- [ ] Ajouter un curseur adapté au redimensionnement.
- [ ] Ajouter des tests widget pour le resize.

## Texte multiligne

- [ ] Remplacer l'édition actuelle par un véritable champ multiligne.
- [ ] Utiliser un `TextField` avec `maxLines: null`.
- [ ] Faire de `Entrée` un retour à la ligne plutôt qu'une validation.
- [ ] Valider l'édition par perte de focus, clic extérieur et/ou `Ctrl+Entrée`.
- [ ] Adapter le rendu du texte dans le `CustomPainter` pour respecter les retours à la ligne et la largeur de la forme.
- [ ] Vérifier le comportement du texte lors du resize d'une forme.
- [ ] Ajouter un test widget spécifique au texte multiligne.

## Couleurs

État actuel :

- [x] Couleur de remplissage (`fillColor`).
- [x] Couleur de contour (`strokeColor`).
- [x] Palettes de couleurs ouvertes avec `MenuAnchor`.
- [x] Menus Fill et Stroke séparés.

Améliorations possibles :

- [ ] Ajouter davantage de couleurs si nécessaire.
- [ ] Éventuellement permettre une couleur personnalisée.
- [ ] Améliorer la visibilité de la couleur blanche dans la palette.

## Sauvegarde et chargement

- [ ] Définir un format de document stable.
- [ ] Sauvegarder les formes, leurs positions, dimensions, textes et couleurs.
- [ ] Sauvegarder les connecteurs.
- [ ] Charger un diagramme existant.
- [ ] Prévoir la compatibilité du format entre versions.
- [ ] Ajouter des tests de sérialisation et de restauration.

## Android release

- [ ] Choisir et figer l'`applicationId` Android.
- [ ] Maintenir la version dans `pubspec.yaml` (`version` + numéro de build).
- [ ] Créer une clé de signature Android dédiée aux releases.
- [ ] Ne jamais stocker le keystore ni ses mots de passe dans Git.
- [ ] Configurer Gradle pour signer les builds `release`.
- [ ] Tester un APK release avec `flutter build apk --release`.
- [ ] Produire un Android App Bundle avec `flutter build appbundle --release` pour Google Play.
- [ ] Stocker les informations de signature nécessaires à la CI dans les secrets GitHub.
- [ ] Faire évoluer le workflow Release pour produire un AAB signé.

## Google Play

- [ ] Créer/configurer le compte développeur Google Play.
- [ ] Préparer le nom définitif, l'icône et les captures d'écran.
- [ ] Préparer les descriptions de l'application (au minimum FR/EN).
- [ ] Fournir une politique de confidentialité si nécessaire.
- [ ] Compléter les déclarations Play Console (Data Safety, contenu, etc.).
- [ ] Passer par les phases de test demandées par Google Play avant la production.
- [ ] Publier l'AAB signé.

## F-Droid

- [ ] Conserver un projet entièrement buildable depuis les sources.
- [ ] Vérifier que toutes les dépendances sont compatibles avec les règles F-Droid.
- [ ] Éviter les dépendances propriétaires incompatibles avec une distribution F-Droid.
- [ ] Veiller à la reproductibilité du build Android.
- [ ] Préparer les métadonnées F-Droid.
- [ ] Proposer l'application au dépôt officiel F-Droid lorsque l'application sera suffisamment stable.

## CI / Releases

État actuel :

- [x] Analyse et tests automatisés.
- [x] Build Linux.
- [x] Build Android APK.
- [x] Création automatique des releases GitHub à partir des tags.
- [x] Tag et release automatiques à chaque merge de PR dans `main` (incrément de patch).
- [x] Artefact "dev" (Android + Linux) généré à la demande sur une PR via le label `build-dev`,
      installable en parallèle de l'app `diagramme` grâce au flavor Android `dev`
      (`applicationId` suffixé `.dev`).

À prévoir :

- [ ] Build Android AAB signé.
- [ ] Éventuellement automatiser davantage la préparation des releases Android.
- [ ] Garder les secrets de signature exclusivement dans l'environnement CI.

## Avant une nouvelle version

1. `flutter analyze`
2. `flutter test`
3. Tester manuellement les fonctions principales.
4. Rebase/fixup des commits WIP si nécessaire.
5. Mettre à jour `TODO.md` : retirer `[WIP]` et passer la fonctionnalité terminée à `[x]`.
6. Merger la PR dans `main`.
7. Créer le nouveau tag de version sur le commit de merge.
8. Pousser le tag.
9. Vérifier le workflow GitHub Actions et les artifacts de la release.
