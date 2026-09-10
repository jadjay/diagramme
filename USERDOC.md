# Diagramme — Guide utilisateur

## Présentation

**Diagramme** est un éditeur simple permettant de créer et manipuler des diagrammes avec des rectangles, des cercles et des connecteurs.

## Barre d'outils

### Sélection

L'outil **Sélection** permet de sélectionner une forme existante, de la déplacer et de modifier ses propriétés.

### Rectangle

Activez l'outil **Rectangle**, puis cliquez ou touchez le canevas pour créer un rectangle.

### Cercle

Activez l'outil **Cercle**, puis cliquez ou touchez le canevas pour créer un cercle.

### Connecteur

Activez l'outil **Connecteur** :

1. cliquez sur une première forme ;
2. cliquez sur une seconde forme ;
3. le connecteur est créé entre les deux.

Une forme ne peut pas être connectée à elle-même.

## Déplacer une forme

Avec l'outil **Sélection**, faites glisser une forme pour la déplacer.

## Redimensionner une forme

Sélectionnez une forme : une petite poignée apparaît à son coin bas-droit. Faites-la glisser pour modifier la taille de la forme.

Pour un cercle, la largeur et la hauteur restent toujours égales, afin qu'il reste bien rond.

Une forme ne peut pas devenir plus petite qu'une taille minimale.

## Déplacer le canevas

Faites glisser une zone vide du canevas.

## Zoom

### Souris

Utilisez la molette de la souris. Le zoom est centré sur la position du pointeur.

### Écran tactile

Utilisez un geste de pincement à deux doigts.

## Modifier le texte d'une forme

Avec l'outil **Sélection**, double-cliquez ou double-touchez une forme pour éditer son texte.

Le champ est multiligne : la touche **Entrée** insère un retour à la ligne. Pour valider et terminer l'édition :

- cliquez à l'extérieur du champ ;
- ou utilisez **Ctrl+Entrée**.

## Couleurs

Après avoir sélectionné une forme :

- utilisez le bouton de couleur de remplissage pour modifier son fond ;
- utilisez le bouton de couleur de contour pour modifier sa bordure.

## Supprimer une forme

Sélectionnez la forme puis utilisez le bouton **Supprimer**.

Sur un ordinateur, les touches **Suppr** et **Retour arrière** peuvent également supprimer la forme sélectionnée lorsqu'aucun texte n'est en cours d'édition.

Les connecteurs liés à une forme supprimée sont automatiquement supprimés.

## Sauvegarder et ouvrir un diagramme

Le bouton **Fichier** (icône dossier, à côté du bouton d'aide) ouvre un menu :

- **Sauvegarder** enregistre le diagramme actuel dans un fichier `.dgm.md` ;
- **Ouvrir** remplace le diagramme actuel par le contenu d'un fichier `.dgm.md`
  choisi sur l'appareil.

Un fichier `.dgm.md` est un document Markdown normal : ouvert comme simple
fichier texte, il reste lisible (le texte des formes n'est pas encodé), et
ouvert dans un lecteur Markdown qui sait afficher des diagrammes Mermaid
(GitHub, GitLab, Obsidian, VS Code...), il s'affiche comme un vrai diagramme.

## Exporter en PNG

Dans le menu **Fichier**, **Exporter en PNG** enregistre une image du
diagramme actuel :

- fond transparent ;
- recadrée au plus près du contenu (pas de marge inutile) ;
- nette à n'importe quelle taille (dessin vectoriel, pas d'agrandissement
  d'image).

## Fonctionnalités prévues

Les évolutions prévues incluent notamment :

- export vers d'autres formats (PDF...) ;
- undo / redo ;
- amélioration des styles et des couleurs.

La roadmap complète est disponible dans `ROADMAP.md`.
