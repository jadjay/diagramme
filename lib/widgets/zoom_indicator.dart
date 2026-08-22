import 'package:flutter/material.dart';

/// Petit indicateur affichant le niveau de zoom courant.
///
/// Il ne connaît rien du canevas ni du diagramme.
/// Il reçoit seulement une valeur [scale].
class ZoomIndicator extends StatelessWidget {
  const ZoomIndicator({
    super.key,
    required this.scale,
  });

  /// Facteur de zoom :
  ///
  /// 1.0  = 100 %
  /// 1.5  = 150 %
  /// 0.75 = 75 %
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${(scale * 100).round()} %',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}