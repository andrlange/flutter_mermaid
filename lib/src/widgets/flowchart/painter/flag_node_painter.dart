import 'dart:math' as math;
import 'node_painter.dart';

class FlagNodePainter extends NodePainter {
  const FlagNodePainter({
    required super.style,
    required super.scaleFactor,
    this.segments = 64, // Mehr Segmente für glatte Wellen
    this.ampFactor = 0.12, // Amplitude relativ zur Höhe
  });

  final int segments;
  final double ampFactor;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Falls NodeStyle width/height hat, diese nutzen
    final double w = _tryGetStyleWidth() ?? size.width;
    final double h = _tryGetStyleHeight() ?? size.height;

    final leftX = inset;
    final rightX = w - inset;

    // Amplitude
    final double amp = math.min(h * ampFactor, 14.0 * scaleFactor);

    // Mittellinien
    final double yTopMid = inset + amp;
    final double yBottomMid = h - inset - amp;

    final path = Path();

    // ===== Obere Welle: volle Sinusperiode (-π .. +π) =====
    double t0 = -math.pi;
    double t1 = math.pi;
    path.moveTo(leftX, yTopMid + amp * math.sin(t0));

    for (int i = 1; i <= segments; i++) {
      final double t = t0 + (t1 - t0) * (i / segments);
      final double x = _lerp(leftX, rightX, i / segments);
      final double y = yTopMid + amp * math.sin(t);
      path.lineTo(x, y);
    }

    // Rechte Kante runter
    path.lineTo(rightX, yBottomMid + amp * math.sin(t1));

    // ===== Untere Welle: auch volle Sinusperiode (-π .. +π) =====
    for (int i = 1; i <= segments; i++) {
      final double t = t1 - (t1 - t0) * (i / segments); // Rückwärts
      final double x = _lerp(rightX, leftX, i / segments);
      final double y = yBottomMid + amp * math.sin(t);
      path.lineTo(x, y);
    }

    // Linke Kante hoch
    path.lineTo(leftX, yTopMid + amp * math.sin(t0));

    path.close();

    // Füllung
    canvas.drawPath(path, createBackgroundPaint());

    // Outline
    final border = createBorderPaint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    drawDashedPath(canvas, path, border);
  }

  double? _tryGetStyleWidth() {
    try {
      final v = (style as dynamic).width;
      if (v is double && v > 0) return v;
    } catch (_) {}
    return null;
  }

  double? _tryGetStyleHeight() {
    try {
      final v = (style as dynamic).height;
      if (v is double && v > 0) return v;
    } catch (_) {}
    return null;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
