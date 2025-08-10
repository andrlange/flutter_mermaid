import 'dart:math' as math;
import 'node_painter.dart';

class CurvedTrapezoidNodePainter extends NodePainter {
  const CurvedTrapezoidNodePainter({
    required super.style,
    required super.scaleFactor,
    this.boxFactor = 0.8, // Anteil der verfügbaren Fläche für das Rechteck
    this.spikeFactor = 0.10, // Länge der linken Spitze relativ zu style.width
    this.minSpikePx = 6.0, // Mindestlänge der Spitze in px
  });

  final double boxFactor;
  final double spikeFactor;
  final double minSpikePx;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Verfügbare Fläche (innen)
    final contentW = math.max(0.0, size.width - 2 * inset);
    final contentH = math.max(0.0, size.height - 2 * inset);

    // Boxgröße
    final boxW = contentW * boxFactor;
    final boxH = contentH * boxFactor;

    // Zentrierte Position
    double left = inset + (contentW - boxW) / 2;
    final top = inset + (contentH - boxH) / 2;
    double rightX = left + boxW;
    final bottom = top + boxH;

    // Rechte Halbkreis-Kappe
    double r = boxH / 2.0;
    final cy = (top + bottom) / 2.0;

    // Sicherstellen, dass die Kappe rechts reinpasst
    final maxR = (inset + contentW) - rightX;
    if (r > maxR) {
      final extra = r - maxR;
      final maxShiftLeft = rightX - inset - boxW;
      final shift = math.min(extra, maxShiftLeft);
      left -= shift;
      rightX -= shift;
    }
    r = math.min(r, (inset + contentW) - rightX);

    // Spike-Länge (links nach außen)
    final styleW = _tryGetStyleWidth() ?? size.width;
    final spikeLen = math.max(styleW * spikeFactor, minSpikePx * scaleFactor);

    // Pfad: oben links → oben rechts → Halbkreis → unten links → Spitze → oben links
    final path = Path()
      ..moveTo(left, top) // oben links
      ..lineTo(rightX, top); // oben rechts (Start Halbkreis)

    // Halbkreis rechts (oben → unten, 180°)
    final circleRect = Rect.fromCircle(center: Offset(rightX, cy), radius: r);
    path.arcTo(circleRect, -math.pi / 2, math.pi, false);

    // Unterkante zurück nach links-unten
    path.lineTo(left, bottom);

    // Spitze: von unten links zur mittigen Spitze nach außen, dann hoch zu oben links
    final tip = Offset(left - spikeLen, cy);
    path
      ..lineTo(tip.dx, tip.dy) // untere Ecke → Spitze
      ..lineTo(left, top) // Spitze → obere Ecke
      ..close();

    // Füllung
    canvas.drawPath(path, createBackgroundPaint());

    // Outline
    final stroke = createBorderPaint()
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    drawDashedPath(canvas, path, stroke);
  }

  double? _tryGetStyleWidth() {
    try {
      final v = (style as dynamic).width;
      if (v is double && v > 0) return v;
    } catch (_) {}
    return null;
  }
}
