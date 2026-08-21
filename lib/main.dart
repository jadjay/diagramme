import 'package:flutter/material.dart';

/// Point d'entrée de l'application.
///
/// C'est l'équivalent du :
///     if __name__ == "__main__":
/// en Python, conceptuellement.
void main() {
  runApp(const DiagrammeApp());
}

/// Widget racine de l'application.
///
/// StatelessWidget = widget sans état interne mutable.
/// Ici, l'application elle-même ne stocke rien :
/// elle se contente d'afficher notre écran principal.
class DiagrammeApp extends StatelessWidget {
  const DiagrammeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Supprime le petit bandeau "DEBUG" en haut à droite.
      debugShowCheckedModeBanner: false,

      // Scaffold fournit une structure de page Flutter classique.
      // Pour l'instant on n'utilise ni AppBar ni boutons :
      // juste notre zone de dessin.
      home: Scaffold(
        body: GridCanvas(),
      ),
    );
  }
}

/// Notre zone de dessin.
///
/// StatefulWidget = widget qui possède un état mutable.
///
/// Ici, l'état à mémoriser est la position de la grille.
/// Quand l'utilisateur déplace la souris, cette position change.
///
/// C'est précisément pour ça qu'on ne peut plus utiliser
/// un StatelessWidget comme avant.
class GridCanvas extends StatefulWidget {
  const GridCanvas({super.key});

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

/// État associé à GridCanvas.
///
/// La convention Flutter met souvent un "_" devant les classes privées.
/// "_GridCanvasState" n'est donc visible que dans ce fichier.
class _GridCanvasState extends State<GridCanvas> {
  /// Décalage actuel du canevas.
  ///
  /// Offset contient deux nombres :
  /// - dx : déplacement horizontal
  /// - dy : déplacement vertical
  ///
  /// Offset.zero signifie :
  /// dx = 0
  /// dy = 0
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    /// GestureDetector permet d'intercepter les gestes utilisateur :
    /// clic, glisser, double clic, etc.
    return GestureDetector(
      /// "opaque" signifie que toute la surface du widget
      /// capture les interactions, même si elle est visuellement vide.
      behavior: HitTestBehavior.opaque,

      /// Cette fonction est appelée pendant un clic-glisser.
      ///
      /// details.delta représente le déplacement DEPUIS
      /// l'événement précédent.
      ///
      /// Exemple :
      /// la souris bouge de 5 px vers la droite :
      /// details.delta.dx == 5
      onPanUpdate: (details) {
        /// setState() indique à Flutter :
        ///
        /// "J'ai modifié une donnée qui affecte l'affichage,
        /// reconstruis ce widget."
        setState(() {
          /// On ajoute le déplacement de la souris
          /// à notre position actuelle.
          ///
          /// Exemple :
          ///
          /// offset = (100, 50)
          /// delta  = (  5, -2)
          ///
          /// nouvel offset = (105, 48)
          offset += details.delta;
        });
      },

      /// SizedBox.expand force son enfant
      /// à prendre toute la place disponible.
      child: SizedBox.expand(
        /// CustomPaint permet de dessiner directement sur un Canvas.
        ///
        /// C'est ici que nous allons faire une grosse partie
        /// de notre moteur de diagrammes.
        child: CustomPaint(
          /// On passe l'offset actuel au peintre.
          ///
          /// Le peintre ne modifie rien :
          /// il reçoit simplement les informations
          /// dont il a besoin pour dessiner.
          painter: GridPainter(offset: offset),
        ),
      ),
    );
  }
}

/// Classe responsable du dessin de la grille.
///
/// CustomPainter donne accès à un Canvas 2D.
/// Ça ressemble beaucoup à une API de dessin classique :
/// lignes, rectangles, cercles, texte, etc.
class GridPainter extends CustomPainter {
  /// Constructeur.
  ///
  /// "required" oblige l'appelant à fournir un offset.
  GridPainter({required this.offset});

  /// Décalage du canevas reçu depuis GridCanvas.
  final Offset offset;

  /// Taille d'une case de la grille.
  ///
  /// Pour l'instant :
  /// 40 unités logiques Flutter.
  ///
  /// Ce n'est PAS encore un centimètre réel.
  static const double gridSize = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    /// Objet décrivant COMMENT dessiner.
    ///
    /// On peut y définir :
    /// couleur, épaisseur, style, etc.
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    /// Ici il y a une petite astuce importante.
    ///
    /// On ne dessine PAS une grille gigantesque.
    /// On dessine uniquement ce qui est visible à l'écran.
    ///
    /// Le modulo (%) donne la position de la première ligne visible.
    ///
    /// Exemple avec gridSize = 40 :
    ///
    /// offset.dx = 53
    ///
    /// 53 % 40 = 13
    ///
    /// donc la première ligne verticale visible sera à x = 13.
    ///
    /// Puis :
    /// 13
    /// 53
    /// 93
    /// 133
    /// etc.
    ///
    /// C'est ce qui donne l'impression
    /// que la grille est infinie.
    final double startX = offset.dx % gridSize;
    final double startY = offset.dy % gridSize;

    /// Dessine les lignes verticales.
    ///
    /// On part de startX et on avance d'une case à chaque fois.
    for (double x = startX; x <= size.width; x += gridSize) {
      canvas.drawLine(
        /// Point de départ : haut de la fenêtre.
        Offset(x, 0),

        /// Point d'arrivée : bas de la fenêtre.
        Offset(x, size.height),

        paint,
      );
    }

    /// Dessine les lignes horizontales.
    for (double y = startY; y <= size.height; y += gridSize) {
      canvas.drawLine(
        /// Départ : bord gauche.
        Offset(0, y),

        /// Arrivée : bord droit.
        Offset(size.width, y),

        paint,
      );
    }
    // ------------------------------------------------------------------
    // Dessin de l'origine du "monde"
    // ------------------------------------------------------------------
    //
    // Notre monde possède un point fixe (0, 0).
    //
    // Au démarrage :
    //   offset = (0, 0)
    // donc l'origine se trouve en haut à gauche.
    //
    // Si on déplace le canevas de :
    //   offset = (200, 100)
    //
    // alors le point (0, 0) du monde apparaît à l'écran en :
    //   x = 200
    //   y = 100
    //
    // Pour le moment, la conversion monde -> écran est donc simplement :
    //
    //   positionEcran = positionMonde + offset
    //
    // Plus tard, avec le zoom, cette formule évoluera.
    
    final originPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;
    
    // Position de l'origine dans les coordonnées de l'écran.
    final Offset origin = offset;
    
    // Petite croix horizontale.
    canvas.drawLine(
      Offset(origin.dx - 10, origin.dy),
      Offset(origin.dx + 10, origin.dy),
      originPaint,
    );
    
    // Petite croix verticale.
    canvas.drawLine(
      Offset(origin.dx, origin.dy - 10),
      Offset(origin.dx, origin.dy + 10),
      originPaint,
    );
  }

  /// Flutter demande ici :
  ///
  /// "Dois-je repeindre le CustomPainter ?"
  ///
  /// Si l'offset a changé, oui.
  ///
  /// Si rien n'a changé, inutile de redessiner.
  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
