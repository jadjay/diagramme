# Roadmap — Diagramme

Cette roadmap décrit l'ordre de travail recommandé pour faire évoluer **Diagramme** d'un éditeur graphique fonctionnel vers une application de diagrammes réellement exploitable.

## Convention de travail des PR

Pour chaque PR fonctionnelle :

1. créer une branche dédiée ;
2. marquer dans `TODO.md` la fonctionnalité travaillée avec le tag `[WIP]` ;
3. développer et tester la fonctionnalité ;
4. juste avant le merge, retirer `[WIP]` et cocher la tâche avec `[x]` ;
5. merger la PR dans `main` ;
6. poser le tag de version sur **le commit de merge** ;
7. la GitHub Release est générée à partir de ce tag.

## Phase 1 — Nettoyage et documentation

- [WIP] Ajouter une documentation utilisateur embarquée (`USERDOC.md`) accessible depuis l'application.
- [WIP] Formaliser la roadmap et le workflow PR / merge / tag / release.
- [ ] Refaire le `README.md` pour présenter réellement le projet.
- [ ] Supprimer les fichiers historiques devenus inutiles (`main.dart_Old`, blocs de test commentés, etc.).

## Phase 2 — Refactorisation du cœur

- [ ] Extraire l'état du document hors de `GridCanvas`.
- [ ] Extraire la logique de sélection et de hit-testing.
- [ ] Extraire la logique pan / zoom / transformation du canevas.
- [ ] Réduire progressivement la taille de `diagram_canvas.dart`.

## Phase 3 — Édition avancée

- [ ] Redimensionnement des formes.
- [ ] Texte multiligne.
- [ ] Amélioration des couleurs et styles.
- [ ] Copier / coller.
- [ ] Undo / redo.

## Phase 4 — Persistance

- [ ] Définir un format de document stable et versionné.
- [ ] Sérialiser formes, connecteurs, styles et textes.
- [ ] Charger un document existant.
- [ ] Ajouter les tests de sérialisation et restauration.

## Phase 5 — Distribution

- [ ] Finaliser l'identifiant Android.
- [ ] Configurer la signature Android.
- [ ] Produire un AAB signé.
- [ ] Préparer les métadonnées F-Droid.
- [ ] Préparer la publication Google Play si souhaitée.
