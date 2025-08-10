import 'dart:math' as math;
import 'node_painter.dart';

class StackedRectangleNodePainter extends NodePainter {
  const StackedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
    this.sizeFactor = 0.9, // 90% der verfügbaren Fläche
    this.shiftFactor = 0.1, // kleiner Versatz (4% der kleineren Kante)
  });

  /// Anteil der Node-Fläche, den jede Box einnimmt (Breite & Höhe)
  final double sizeFactor;

  /// Relativer Versatz der hinteren Boxen (bezogen auf min(contentW, contentH))
  final double shiftFactor;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Verfügbare Fläche abzüglich Rand
    final contentW = math.max(0.0, size.width - inset * 2);
    final contentH = math.max(0.0, size.height - inset * 2);

    // Zielgröße: 90% der verfügbaren Fläche
    final w = contentW * sizeFactor;
    final h = contentH * sizeFactor;

    // Kleiner Shift nach oben rechts
    final base = math.min(contentW, contentH);
    final shift = math.max(base * shiftFactor, 2.0 * scaleFactor);

    // Vorderste Box: unten links ausgerichtet (nicht transparent)
    final frontLeft = Offset(inset, inset + (contentH - h));
    final frontRect = Rect.fromLTWH(frontLeft.dx, frontLeft.dy, w, h);

    // Mittlere Box: leicht nach oben rechts
    final midRect = frontRect.shift(Offset(shift, -shift));

    // Hinterste Box: noch ein bisschen weiter nach oben rechts
    final backRect = frontRect.shift(Offset(2 * shift, -2 * shift));

    // Paints
    final bgFront = createBackgroundPaint(); // volle Deckkraft
    final bgMid = Paint()
      ..color = style.backgroundColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final bgBack = Paint()
      ..color = style.backgroundColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final borderFront = createBorderPaint();
    final borderMid = Paint()
      ..color = style.borderColor.withValues(alpha: 0.9)
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke;
    final borderBack = Paint()
      ..color = style.borderColor.withValues(alpha: 0.75)
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke;

    // Zeichnen: von hinten nach vorne
    canvas.drawRect(backRect, bgBack);
    drawDashedPath(canvas, Path()..addRect(backRect), borderBack);

    canvas.drawRect(midRect, bgMid);
    drawDashedPath(canvas, Path()..addRect(midRect), borderMid);

    canvas.drawRect(frontRect, bgFront); // unten links, nicht transparent
    drawDashedPath(canvas, Path()..addRect(frontRect), borderFront);
  }
}

class DelayNopePainter extends NodePainter {
  const DelayNopePainter({
    required super.style,
    required super.scaleFactor,
    this.boxFactor = 0.6, // 80% von Breite/Höhe
  });

  /// Anteil der verfügbaren Fläche, den die Box (ohne Halbkreis) einnimmt.
  final double boxFactor;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Verfügbare Fläche innerhalb des Randes
    final contentW = math.max(0.0, size.width - 2 * inset);
    final contentH = math.max(0.0, size.height - 2 * inset);

    // Zielgröße: 80% Breite/Höhe
    final boxW = contentW * boxFactor;
    final boxH = contentH * boxFactor;

    // Grund-Position: zentriert
    double left = inset + (contentW - boxW) / 2;
    final top = inset + (contentH - boxH) / 2;
    double rightX = left + boxW;
    final bottom = top + boxH;

    // Halbkreis-Geometrie (Durchmesser = Box-Höhe)
    double r = boxH / 2.0;
    final cy = (top + bottom) / 2.0;

    // Sicherstellen, dass der Halbkreis rechts nicht aus dem Content-Bereich ragt.
    // Maximal erlaubter Radius, damit x_max <= inset + contentW.
    final maxR = (inset + contentW) - rightX;
    if (r > maxR) {
      // Schiebe die Box so weit nach links, dass der Halbkreis hineinpasst,
      // solange links noch Platz ist.
      final extra = r - maxR;
      final maxShiftLeft =
          rightX - inset - boxW; // wie weit können wir nach links gehen
      final shift = math.min(extra, maxShiftLeft);
      left -= shift;
      rightX -= shift;
    }

    // Falls immer noch zu groß (extreme Seitenverhältnisse), Radius begrenzen:
    r = math.min(r, (inset + contentW) - rightX);

    // Path: oben links → oben rechts (Boxkante) → Halbkreis nach unten →
    // unten links → schließen
    final path = Path()
      ..moveTo(left, top) // oben links
      ..lineTo(rightX, top); // oben rechts (Startpunkt des Halbkreises)

    // Halbkreis (rechts) – Bounding-Rect des Vollkreises
    final circleRect = Rect.fromCircle(center: Offset(rightX, cy), radius: r);

    // Von oben (Startwinkel -90°) nach unten (+90°), positive Sweep (clockwise)
    path.arcTo(
      circleRect,
      -math.pi / 2, // Start: oben
      math.pi, // 180° Bogen nach unten
      false,
    );

    // Untere Kante zurück nach links
    path
      ..lineTo(left, bottom)
      ..close();

    // Füllung
    canvas.drawPath(path, createBackgroundPaint());

    // Outline (ggf. gestrichelt)
    final stroke = createBorderPaint()
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    drawDashedPath(canvas, path, stroke);
  }
}
