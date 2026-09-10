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

- [x] Ajouter une seule poignée de redimensionnement en bas à droite de la forme sélectionnée
      (`ShapeResizeHandle`, visible uniquement en mode Sélection hors édition de texte).
- [x] Utiliser le même principe pour les rectangles et les cercles
      (même coin de la boîte englobante ; un cercle garde `width == height`).
- [x] Gérer le drag de la poignée pour modifier `width` et `height`
      (`DiagramShape.resizeBy`, piloté par `onScaleStart`/`onScaleUpdate` de GridCanvas).
- [x] Définir une taille minimale afin d'éviter les formes trop petites ou les dimensions négatives
      (`DiagramShape.minSize`).
- [x] Ajouter un curseur adapté au redimensionnement (`SystemMouseCursors.resizeUpLeftDownRight`).
- [x] Ajouter des tests widget pour le resize (`test/widget_test.dart`), plus des tests
      unitaires pour `DiagramShape.resizeBy` (`test/diagram_shape_test.dart`).

## Texte multiligne

- [x] Remplacer l'édition actuelle par un véritable champ multiligne.
- [x] Utiliser un `TextField` avec `maxLines: null`.
- [x] Faire de `Entrée` un retour à la ligne plutôt qu'une validation.
- [x] Valider l'édition par clic extérieur (`TapRegion.onTapOutside`) et/ou
      `Ctrl+Entrée` (`Focus.onKeyEvent`) — `onSubmitted` reste aussi disponible
      pour un éventuel "done" explicite de la plateforme.
- [x] Adapter le rendu du texte dans le `CustomPainter` pour respecter les retours
      à la ligne et la largeur de la forme (déjà pris en charge par
      `TextPainter`/`maxWidth` ; ajout d'un `clipRect` pour qu'un texte trop haut
      ne dépasse jamais visuellement de la forme).
- [x] Vérifier le comportement du texte lors du resize d'une forme (recalculé à
      chaque frame de dessin, donc déjà correct ; test dédié ajouté).
- [x] Ajouter des tests widget spécifiques au texte multiligne (`test/widget_test.dart`) :
      Entrée insère un retour à la ligne, Ctrl+Entrée valide, clic extérieur valide,
      clic à l'intérieur du champ ne valide pas, comportement pendant un resize.

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

Format retenu : `.dgm.md`, un document Markdown normal composé de deux
parties (voir `lib/persistence/diagram_file_format.dart` pour le détail) :

1. un en-tête YAML (frontmatter, délimité par `---`), seule source de
   vérité relue par l'application : formes, connecteurs, positions,
   tailles, couleurs, textes ;
2. un bloc ```mermaid``` régénéré à chaque sauvegarde (non relu au
   chargement), qui permet au fichier de s'afficher comme un vrai
   diagramme dans un lecteur Markdown (GitHub, GitLab, Obsidian, VS
   Code...).

Le texte des formes est stocké en clair (bloc littéral YAML `|`, sans
échappement) : ouvert comme simple fichier texte, il reste directement
réutilisable dans un document Markdown ou LaTeX.

- [x] Définir un format de document stable (`.dgm.md`) et versionné
      (`diagramFileFormatVersion`, actuellement `1`).
- [x] Sauvegarder les formes, leurs positions, dimensions, textes et couleurs
      (`encodeDiagramDocument`).
- [x] Sauvegarder les connecteurs (`encodeDiagramDocument`).
- [x] Charger un diagramme existant : bouton "Fichier" (icône dossier, à côté
      du bouton d'aide) ouvrant un menu Sauvegarder/Ouvrir, basé sur
      `file_picker` pour le sélecteur de fichier natif Android/Linux
      (`lib/main.dart`, `GridCanvasState.exportDocument`/`importDocument`).
      Un fichier invalide (mauvaise version, en-tête absent...) affiche un
      message d'erreur plutôt que de planter.
- [x] Prévoir la compatibilité du format entre versions (un fichier dont la
      version ne correspond pas à `diagramFileFormatVersion` est refusé avec
      un message explicite ; la logique de migration proprement dite reste à
      écrire le jour où le format évoluera).
- [x] Ajouter des tests de sérialisation et de restauration
      (`test/diagram_file_format_test.dart`, `test/diagram_document_test.dart`).

Prévu pour plus tard :

- [ ] Exporter vers un autre format (image, PDF...) — entrée de menu déjà
      réservée ("Exporter (bientôt)"), volontairement désactivée pour l'instant.

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
