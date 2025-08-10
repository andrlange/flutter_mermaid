import 'dart:math' as math;
import 'node_painter.dart';

class TaggedRectangleNodePainter extends NodePainter {
  const TaggedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
    this.tagOffsetFactor =
        0.10, // Abstand zur Ecke relativ zur Breite (z.B. 0.1 * Breite)
    this.minTagOffsetPx = 6.0, // untere Grenze in Pixeln
  });

  /// Relativer Abstand der Diagonale von der Ecke (bezogen auf die verfügbare Breite).
  final double tagOffsetFactor;

  /// Minimale absolute Distanz in Pixeln, falls die Node sehr klein ist.
  final double minTagOffsetPx;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Innenfläche des Rechtecks
    final rect = Rect.fromLTWH(
      inset,
      inset,
      math.max(0, size.width - 2 * inset),
      math.max(0, size.height - 2 * inset),
    );

    // Grundform: Hintergrund + Rand
    final path = Path()..addRect(rect);
    canvas.drawPath(path, createBackgroundPaint());
    drawDashedPath(canvas, path, createBorderPaint());

    // ----- Diagonaler "Tag" unten rechts (innenliegend) -----
    // Abstand bestimmen: Anteil an der Breite, mit Mindestgrenze
    final tagOffset = math.max(
      rect.width * tagOffsetFactor,
      minTagOffsetPx * scaleFactor,
    );

    // leicht nach innen versetzen, damit die Linie nicht mit dem Außenrand kollidiert
    final innerPad = math.max(1.0, style.borderWidth * 0.5);

    final start = Offset(
      rect.right - tagOffset - innerPad,
      rect.bottom - innerPad,
    ); // unten, nach links versetzt
    final end = Offset(
      rect.right - innerPad,
      rect.bottom - tagOffset - innerPad,
    ); // rechts, nach oben versetzt

    final tagPaint = Paint()
      ..color = style.borderColor
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, tagPaint);
  }
}
