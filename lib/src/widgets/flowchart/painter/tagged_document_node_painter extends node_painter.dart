import 'dart:math' as math;
import 'node_painter.dart';

class TaggedDocumentNodePainter extends NodePainter {
  const TaggedDocumentNodePainter({
    required super.style,
    required super.scaleFactor,
    this.tagOffsetFactor = 0.10, // Abstand zur Ecke in Breite-Anteilen
    this.minTagOffsetPx = 6.0,
    this.samples = 64, // Auflösung für Punktsuche auf der Bezier
  });

  final double tagOffsetFactor;
  final double minTagOffsetPx;
  final int samples;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveHeight = math.min(size.height * 0.3, 10.0);

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, size.height - waveHeight - inset);

    // Welle (kubische Bezier)
    final startX = size.width - inset;
    final endX = inset;
    final waveY = size.height - inset;

    final p0 = Offset(
      startX,
      size.height - waveHeight - inset,
    ); // Start der Welle (rechts)
    final p1 = Offset(startX * 0.66, waveY + waveHeight);
    final p2 = Offset(startX * 0.33, waveY - waveHeight);
    final p3 = Offset(endX, waveY);

    path.cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);
    path
      ..lineTo(inset, size.height - waveHeight - inset)
      ..close();

    // Füllung + Outline
    canvas.drawPath(path, createBackgroundPaint());
    drawDashedPath(canvas, path, createBorderPaint());

    // ===============================
    // Diagonale unten rechts (innen)
    // Start: exakt auf der Welle, links von der Ecke
    // Abstand = 0.1 * Breite (mit Mindestgrenze)
    // ===============================
    final rectWidth = size.width - 2 * inset;
    final tagOffset = math.max(
      rectWidth * tagOffsetFactor,
      minTagOffsetPx * scaleFactor,
    );
    final innerPad = math.max(1.0, style.borderWidth * 0.5);

    final rightX = size.width - inset;
    final desiredX =
        rightX - tagOffset; // x-Position auf der Welle links neben der Ecke

    // Punkt auf der Bezier suchen, dessen x in etwa desiredX ist
    final startOnWave = _pointOnCubicAtX(
      p0,
      p1,
      p2,
      p3,
      desiredX,
      samples: samples,
    );

    // Endpunkt: an der rechten Kante, oberhalb der Ecke, gleicher Abstand
    final bottomRightY = p0.dy; // = size.height - waveHeight - inset
    final end = Offset(rightX - innerPad, bottomRightY - tagOffset - innerPad);

    final tagPaint = Paint()
      ..color = style.borderColor
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Diagonale zeichnen (Start exakt auf der Welle)
    canvas.drawLine(Offset(startOnWave.dx, startOnWave.dy), end, tagPaint);
  }

  /// Grobe Suche entlang der kubischen Bezier (monoton fallendes x in deinem Fall).
  /// Gibt den Punkt zurück, dessen x am nächsten bei desiredX liegt.
  Offset _pointOnCubicAtX(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double desiredX, {
    int samples = 64,
  }) {
    var prev = p0;

    for (var i = 1; i <= samples; i++) {
      final t = i / samples;
      final pt = _cubicPoint(p0, p1, p2, p3, t);

      // Wir suchen die Stelle, wo x von >desiredX auf <=desiredX geht
      if ((prev.dx >= desiredX && pt.dx <= desiredX) || i == samples) {
        // Linear zwischen prev und pt interpolieren für bessere Näherung
        final denom = (prev.dx - pt.dx);
        final local = denom.abs() < 1e-6
            ? 0.0
            : ((prev.dx - desiredX) / denom).clamp(0.0, 1.0);
        final x = prev.dx + (pt.dx - prev.dx) * local;
        final y = prev.dy + (pt.dy - prev.dy) * local;
        return Offset(x, y);
      }

      prev = pt;
      //prevT = t;
    }

    return p0; // fallback (sollte praktisch nicht passieren)
  }

  Offset _cubicPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final mt = 1 - t;
    final a = mt * mt * mt;
    final b = 3 * mt * mt * t;
    final c = 3 * mt * t * t;
    final d = t * t * t;
    return Offset(
      a * p0.dx + b * p1.dx + c * p2.dx + d * p3.dx,
      a * p0.dy + b * p1.dy + c * p2.dy + d * p3.dy,
    );
  }
}
