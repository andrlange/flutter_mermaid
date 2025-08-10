import 'node_painter.dart';

class CommentLeftNodePainter extends NodePainter {
  const CommentLeftNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final centerY = size.height / 2;

    // Sehr schmale Klammer - nur 15% der Breite verwenden
    final braceWidth = size.width * 0.15;
    final braceDepth = braceWidth * 0.4; // Tiefe der Einbuchtung
    final armHeight = size.height * 0.35; // Höhe der Arme

    final path = Path()
      // Start top right der Klammer
      ..moveTo(braceWidth, inset)
      // Curve nach links oben
      ..quadraticBezierTo(inset, inset, inset, centerY - armHeight)
      // Line zur Mitte-Einbuchtung
      ..lineTo(inset, centerY - braceDepth)
      // Center point (die Spitze der Klammer nach links)
      ..lineTo(inset - braceDepth, centerY)
      ..lineTo(inset, centerY + braceDepth)
      // Line nach unten
      ..lineTo(inset, centerY + armHeight)
      // Curve nach links unten
      ..quadraticBezierTo(
        inset,
        size.height - inset,
        braceWidth,
        size.height - inset,
      );

    // Nur Umriss zeichnen, keine Füllung
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
