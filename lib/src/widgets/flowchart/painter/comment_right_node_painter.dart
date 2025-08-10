import 'node_painter.dart';

class CommentRightNodePainter extends NodePainter {
  const CommentRightNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final centerY = size.height / 2;

    // Sehr schmale Klammer - nur 15% der Breite verwenden, am rechten Rand
    final braceWidth = size.width * 0.15;
    final braceStart = size.width - braceWidth; // Start der Klammer von rechts
    final braceDepth = braceWidth * 0.4; // Tiefe der Einbuchtung
    final armHeight = size.height * 0.35; // Höhe der Arme

    final path = Path()
      // Start top left der Klammer
      ..moveTo(braceStart, inset)
      // Curve nach rechts oben
      ..quadraticBezierTo(
        size.width - inset,
        inset,
        size.width - inset,
        centerY - armHeight,
      )
      // Line zur Mitte-Einbuchtung
      ..lineTo(size.width - inset, centerY - braceDepth)
      // Center point (die Spitze der Klammer nach rechts)
      ..lineTo(size.width - inset + braceDepth, centerY)
      ..lineTo(size.width - inset, centerY + braceDepth)
      // Line nach unten
      ..lineTo(size.width - inset, centerY + armHeight)
      // Curve nach rechts unten
      ..quadraticBezierTo(
        size.width - inset,
        size.height - inset,
        braceStart,
        size.height - inset,
      );

    // Nur Umriss zeichnen, keine Füllung
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
