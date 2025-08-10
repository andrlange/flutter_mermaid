import 'node_painter.dart';

class BracesNodePainter extends NodePainter {
  const BracesNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final centerY = size.height / 2;

    // Sehr schmale Klammern - jeweils 15% der Breite verwenden
    final braceWidth = size.width * 0.15;
    final braceDepth = braceWidth * 0.4; // Tiefe der Einbuchtung
    final armHeight = size.height * 0.35; // Höhe der Arme
    final rightBraceStart =
        size.width - braceWidth; // Start der rechten Klammer

    // LINKE KLAMMER "{"
    final leftPath = Path()
      // Start top right der linken Klammer
      ..moveTo(braceWidth, inset)
      // Curve nach links oben
      ..quadraticBezierTo(inset, inset, inset, centerY - armHeight)
      // Line zur Mitte-Einbuchtung
      ..lineTo(inset, centerY - braceDepth)
      // Center point (die Spitze nach links)
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

    // RECHTE KLAMMER "}"
    final rightPath = Path()
      // Start top left der rechten Klammer
      ..moveTo(rightBraceStart, inset)
      // Curve nach rechts oben
      ..quadraticBezierTo(
        size.width - inset,
        inset,
        size.width - inset,
        centerY - armHeight,
      )
      // Line zur Mitte-Einbuchtung
      ..lineTo(size.width - inset, centerY - braceDepth)
      // Center point (die Spitze nach rechts)
      ..lineTo(size.width - inset + braceDepth, centerY)
      ..lineTo(size.width - inset, centerY + braceDepth)
      // Line nach unten
      ..lineTo(size.width - inset, centerY + armHeight)
      // Curve nach rechts unten
      ..quadraticBezierTo(
        size.width - inset,
        size.height - inset,
        rightBraceStart,
        size.height - inset,
      );

    // Beide Klammern zeichnen
    final borderPaint = createBorderPaint();
    drawDashedPath(canvas, leftPath, borderPaint);
    drawDashedPath(canvas, rightPath, borderPaint);
  }
}
