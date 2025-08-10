import 'dart:math' as math;
import 'node_painter.dart';

class HourglassNodePainter extends NodePainter {
  const HourglassNodePainter({
    required super.style,
    required super.scaleFactor,
    this.narrowFactor =
        0.15, // wie stark links/rechts „eingezogen“ wird (0..0.4 typisch)
  });

  /// Anteil der Breite, um den links/rechts eingezogen wird.
  final double narrowFactor;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Schmaler machen: horizontales Innen-Offset
    final innerPad = math.max(size.width * narrowFactor, 6.0 * scaleFactor);

    final leftX = inset + innerPad;
    final rightX = size.width - inset - innerPad;
    final topY = inset;
    final botY = size.height - inset;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      // obere Kante
      ..moveTo(leftX, topY)
      ..lineTo(rightX, topY)
      // rechte Diagonale nach Mitte (Kreuzungspunkt)
      ..lineTo(centerX, centerY)
      // rechte Außenkante unten
      ..lineTo(rightX, botY)
      // untere Kante
      ..lineTo(leftX, botY)
      // linke Diagonale zurück zur Mitte (Kreuzungspunkt)
      ..lineTo(centerX, centerY)
      ..close();

    // Hintergrund
    canvas.drawPath(path, createBackgroundPaint());

    // Rand
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
