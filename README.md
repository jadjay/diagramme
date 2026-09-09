# Diagramme

**Diagramme** est un éditeur de diagrammes développé avec [Flutter](https://flutter.dev),
pour Linux et Android. Il permet de créer et manipuler des rectangles, des
cercles et des connecteurs sur un canevas avec pan et zoom.

## Fonctionnalités actuelles

- Création de rectangles et de cercles.
- Connecteurs entre deux formes.
- Sélection, déplacement et suppression des formes (le clavier
  Suppr/Retour arrière fonctionne aussi).
- Pan et zoom du canevas (molette souris, pincement tactile).
- Édition du texte d'une forme (double-clic / double-tap).
- Couleurs de remplissage et de contour personnalisables.
- Documentation utilisateur embarquée dans l'application (bouton d'aide).

Le détail d'utilisation est dans [`USERDOC.md`](USERDOC.md).

Ce que le projet ne fait pas encore — sauvegarde/chargement de document,
undo/redo, redimensionnement des formes, texte multiligne — est suivi dans
[`TODO.md`](TODO.md) et priorisé dans [`ROADMAP.md`](ROADMAP.md).

## Démarrer le projet

Prérequis : [Flutter](https://docs.flutter.dev/get-started/install)
(SDK `^3.13.1`, voir `pubspec.yaml`).

```sh
flutter pub get
flutter run
```

Le projet cible **Linux** et **Android**. Sur Android, l'application
utilise deux flavors Gradle :

- `prod` : l'application publiée (`local.jerome.diagramme`) ;
- `dev` : artefact de test généré à la demande sur les PR
  (`local.jerome.diagramme.dev`), installable en parallèle de la
  version `prod` sur le même appareil.

```sh
flutter run --flavor prod   # ou --flavor dev
```

## Tests et analyse statique

```sh
flutter analyze
flutter test
```

## Intégration continue et releases

- Chaque push et chaque PR vers `main` exécutent `flutter analyze` et
  `flutter test` (`.github/workflows/build.yml`).
- Chaque merge d'une PR dans `main` pose automatiquement un tag de
  version et publie une GitHub Release avec un APK Android et une
  archive Linux (`.github/workflows/auto-tag.yml` et `release.yml`).
- Un APK et une archive Linux "dev" peuvent être générés à la demande
  sur une PR en ajoutant le label `build-dev`
  (`.github/workflows/build-dev.yml`).

Le workflow de contribution complet (branche, `TODO.md`, PR, tag,
release) est décrit dans [`ROADMAP.md`](ROADMAP.md).

## Licence

Ce projet est sous licence [GPL-3.0](LICENSE).
