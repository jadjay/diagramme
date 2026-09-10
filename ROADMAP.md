# Roadmap — Diagramme

Cette roadmap décrit l'ordre de travail recommandé pour faire évoluer **Diagramme** d'un éditeur graphique fonctionnel vers une application de diagrammes réellement exploitable.

## Convention de travail des PR

Pour chaque PR fonctionnelle :

1. créer une branche dédiée ;
2. marquer dans `TODO.md` la fonctionnalité travaillée avec le tag `[WIP]` ;
3. développer et tester la fonctionnalité ;
   - possibilité de générer à la demande un artefact de test (`diagramme-dev`,
     installable en parallèle de l'app standard) en ajoutant le label
     `build-dev` sur la PR (voir `.github/workflows/build-dev.yml`) ;
4. juste avant le merge, retirer `[WIP]` et cocher la tâche avec `[x]` ;
5. merger la PR dans `main` (avec un commit de merge) ;
6. si la PR contient au moins un commit `feat:` ou `fix:`, le tag de
   version (incrément de patch) est posé automatiquement sur **le
   commit de merge** par `.github/workflows/auto-tag.yml` ; une PR dont
   tous les commits sont `refactor:`/`docs:`/`chore:`/`ci:`/`test:`/...
   (aucun changement utilisateur) est mergée normalement mais ne
   produit ni tag ni release ;
7. la GitHub Release est générée automatiquement à partir de ce tag.

## Phase 1 — Nettoyage et documentation

- [x] Ajouter une documentation utilisateur embarquée (`USERDOC.md`) accessible depuis l'application.
- [x] Formaliser la roadmap et le workflow PR / merge / tag / release.
- [x] Refaire le `README.md` pour présenter réellement le projet.
- [x] Supprimer les fichiers historiques devenus inutiles (`main.dart_Old`, blocs de test commentés, etc.).

## Phase 2 — Refactorisation du cœur

- [x] Extraire l'état du document hors de `GridCanvas` (`DiagramDocument`
      dans `lib/models/diagram_document.dart` : formes, connecteurs,
      sélection, et les mutations qui leur sont propres — création de
      forme, workflow connecteur, suppression).
- [x] Extraire la logique de sélection et de hit-testing (`ShapeHitTester`
      dans `lib/models/shape_hit_tester.dart`, testé indépendamment de
      tout widget).
- [x] Extraire la logique pan / zoom / transformation du canevas
      (`CanvasViewport` dans `lib/models/canvas_viewport.dart`, testé
      indépendamment de tout widget).
- [x] Réduire progressivement la taille de `diagram_canvas.dart` — conséquence
      des trois extractions précédentes, plus l'extraction du champ de texte
      superposé vers `ShapeTextEditor` (`lib/widgets/shape_text_editor.dart`).
      1019 → 526 lignes (-48 %), sans changement de comportement.

## Phase 3 — Édition avancée

- [x] Redimensionnement des formes (poignée unique en bas à droite,
      voir `TODO.md` pour le détail).
- [x] Texte multiligne (champ `maxLines: null`, validation par clic
      extérieur ou Ctrl+Entrée, voir `TODO.md` pour le détail).
- [ ] Texte multiligne.
- [ ] Amélioration des couleurs et styles.
- [ ] Copier / coller.
- [ ] Undo / redo.

## Phase 4 — Persistance

- [x] Définir un format de document stable et versionné (`.dgm.md` :
      Markdown avec en-tête YAML, voir `TODO.md` pour le détail).
- [x] Sérialiser formes, connecteurs, styles et textes.
- [ ] Charger un document existant (sélecteur de fichier Android/Linux,
      boutons Sauvegarder/Ouvrir).
- [x] Ajouter les tests de sérialisation et restauration.

## Phase 5 — Distribution

- [ ] Finaliser l'identifiant Android.
- [ ] Configurer la signature Android.
- [ ] Produire un AAB signé.
- [ ] Préparer les métadonnées F-Droid.
- [ ] Préparer la publication Google Play si souhaitée.
