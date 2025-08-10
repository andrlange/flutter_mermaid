// =============================================================================
// BASE NODE PAINTER INTERFACE
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../styles/node_styles.dart';

abstract class NodePainter extends CustomPainter {
  const NodePainter({required this.style, required this.scaleFactor});

  final NodeStyle style;
  final double scaleFactor;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  /// Draw the node shape within the given size
  void drawShape(Canvas canvas, Size size);

  @override
  void paint(Canvas canvas, Size size) {
    drawShape(canvas, size);
  }

  /// Helper method to create paint with border style
  Paint createBorderPaint() {
    final paint = Paint()
      ..color = style.borderColor
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke;

    return paint;
  }

  /// Helper method to create background paint
  Paint createBackgroundPaint() {
    return Paint()
      ..color = style.backgroundColor
      ..style = PaintingStyle.fill;
  }

  /// Helper method to draw dashed path
  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    if (!style.isDashed) {
      canvas.drawPath(path, paint);
      return;
    }

    final dashWidth = style.borderWidth * 3;
    final dashSpace = style.borderWidth * 2;

    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      var distance = 0.0;
      var draw = true;

      while (distance < pathMetric.length) {
        final segmentLength = draw ? dashWidth : dashSpace;
        final segment = pathMetric.extractPath(
          distance,
          distance + segmentLength,
        );

        if (draw) {
          canvas.drawPath(segment, paint);
        }

        distance += segmentLength;
        draw = !draw;
      }
    }
  }
}

// =============================================================================
// ALL OTHER NODE PAINTER
// =============================================================================

class RectangleNodePainter extends NodePainter {
  const RectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      style.borderWidth / 2,
      style.borderWidth / 2,
      size.width - style.borderWidth,
      size.height - style.borderWidth,
    );

    // Draw background
    canvas.drawRect(rect, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, borderPaint);
  }
}

class TaggedRectangleNodePainter extends NodePainter {
  const TaggedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
    this.tagOffsetFactor = 0.10, // Abstand zur Ecke relativ zur Breite (z.B. 0.1 * Breite)
    this.minTagOffsetPx = 6.0,   // untere Grenze in Pixeln
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
      math.max(0, size.width  - 2 * inset),
      math.max(0, size.height - 2 * inset),
    );

    // Grundform: Hintergrund + Rand
    final path = Path()..addRect(rect);
    canvas.drawPath(path, createBackgroundPaint());
    drawDashedPath(canvas, path, createBorderPaint());

    // ----- Diagonaler "Tag" unten rechts (innenliegend) -----
    // Abstand bestimmen: Anteil an der Breite, mit Mindestgrenze
    final tagOffset = math.max(rect.width * tagOffsetFactor, minTagOffsetPx * scaleFactor);

    // leicht nach innen versetzen, damit die Linie nicht mit dem Außenrand kollidiert
    final innerPad = math.max(1.0, style.borderWidth * 0.5);

    final start = Offset(rect.right - tagOffset - innerPad, rect.bottom - innerPad); // unten, nach links versetzt
    final end   = Offset(rect.right - innerPad, rect.bottom - tagOffset - innerPad); // rechts, nach oben versetzt

    final tagPaint = Paint()
      ..color = style.borderColor
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, tagPaint);
  }
}

class CircleNodePainter extends NodePainter {
  const CircleNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (math.min(size.width, size.height) / 2) - (style.borderWidth / 2);

    // Draw background
    canvas.drawCircle(center, radius, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    drawDashedPath(canvas, path, borderPaint);
  }
}

class DiamondNodePainter extends NodePainter {
  const DiamondNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    //final halfWidth = (size.width / 2) - (style.borderWidth / 2);
    //final halfHeight = (size.height / 2) - (style.borderWidth / 2);

    final path = Path()
      ..moveTo(centerX, style.borderWidth / 2)
      ..lineTo(size.width - (style.borderWidth / 2), centerY)
      ..lineTo(centerX, size.height - (style.borderWidth / 2))
      ..lineTo(style.borderWidth / 2, centerY)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class StadiumNodePainter extends NodePainter {
  const StadiumNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final rect = RRect.fromLTRBR(
      style.borderWidth / 2,
      style.borderWidth / 2,
      size.width - (style.borderWidth / 2),
      size.height - (style.borderWidth / 2),
      Radius.circular(size.height / 2),
    );

    // Draw background
    canvas.drawRRect(rect, createBackgroundPaint());

    // Draw border
    final path = Path()..addRRect(rect);
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class HexagonNodePainter extends NodePainter {
  const HexagonNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    //final centerX = size.width / 2;
    final centerY = size.height / 2;
    final inset = style.borderWidth / 2;
    final sideWidth = size.width * 0.2; // 20% for angled sides

    final path = Path()
      ..moveTo(sideWidth + inset, inset)
      ..lineTo(size.width - sideWidth - inset, inset)
      ..lineTo(size.width - inset, centerY)
      ..lineTo(size.width - sideWidth - inset, size.height - inset)
      ..lineTo(sideWidth + inset, size.height - inset)
      ..lineTo(inset, centerY)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class CylinderNodePainter extends NodePainter {
  const CylinderNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final topHeight = size.height * 0.2;

    // Main cylinder body
    final bodyRect = Rect.fromLTWH(
      inset,
      topHeight / 2,
      size.width - (inset * 2),
      size.height - topHeight - inset,
    );

    // Top ellipse
    final topEllipse = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      topHeight,
    );

    // Bottom ellipse (used for clipping the arc)
    final bottomEllipse = Rect.fromLTWH(
      inset,
      size.height - topHeight - inset,
      size.width - (inset * 2),
      topHeight,
    );

    final backgroundPaint = createBackgroundPaint();
    final borderPaint = createBorderPaint();

    // Draw background
    canvas.drawRect(bodyRect, backgroundPaint);
    canvas.drawOval(topEllipse, backgroundPaint);

    // Draw border sides
    final left = Offset(inset, topHeight / 2);
    final right = Offset(size.width - inset, topHeight / 2);
    final bottomLeft = Offset(inset, size.height - topHeight / 2);
    final bottomRight = Offset(size.width - inset, size.height - topHeight / 2);

    canvas.drawLine(left, bottomLeft, borderPaint);
    canvas.drawLine(right, bottomRight, borderPaint);

    // Draw top ellipse (full)
    final topPath = Path()..addOval(topEllipse);
    drawDashedPath(canvas, topPath, borderPaint);

    // Draw bottom front arc (half ellipse)
    final bottomArcPath = Path()
      ..moveTo(inset, size.height - topHeight / 2)
      ..arcTo(
        bottomEllipse,
        math.pi, // Start at 180° (left side)
        -math.pi, // Sweep -180° to draw lower half (front)
        false,
      );

    drawDashedPath(canvas, bottomArcPath, borderPaint);
  }
}

class LinedCylinderNodePainter extends NodePainter {
  const LinedCylinderNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final topHeight = size.height * 0.2;
    final gap = topHeight * 0.4; // Abstand für oberen Kreis
    final ellipseHeight = topHeight;

    final bodyTop = gap + ellipseHeight / 2;
    final bodyBottom = size.height - ellipseHeight / 2 - inset;

    // Main cylinder body
    final bodyRect = Rect.fromLTRB(
      inset,
      bodyTop,
      size.width - inset,
      bodyBottom,
    );

    // Top ellipse (on cylinder body)
    final topEllipse = Rect.fromLTWH(
      inset,
      bodyTop - ellipseHeight / 2,
      size.width - (inset * 2),
      ellipseHeight,
    );

    // Bottom ellipse (front arc only)
    final bottomEllipse = Rect.fromLTWH(
      inset,
      bodyBottom - ellipseHeight / 2,
      size.width - (inset * 2),
      ellipseHeight,
    );

    // Detached ellipse on top (above main cylinder)
    final detachedEllipse = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      ellipseHeight,
    );

    final backgroundPaint = createBackgroundPaint();
    final borderPaint = createBorderPaint();

    // Draw background shapes
    canvas.drawRect(bodyRect, backgroundPaint);
    canvas.drawOval(topEllipse, backgroundPaint);
    canvas.drawOval(detachedEllipse, backgroundPaint);

    // Draw sides of main cylinder
    final left = Offset(inset, bodyTop);
    final right = Offset(size.width - inset, bodyTop);
    final bottomLeft = Offset(inset, bodyBottom);
    final bottomRight = Offset(size.width - inset, bodyBottom);

    canvas.drawLine(left, bottomLeft, borderPaint);
    canvas.drawLine(right, bottomRight, borderPaint);

    // Top ellipse (on cylinder body)
    final topPath = Path()..addOval(topEllipse);
    drawDashedPath(canvas, topPath, borderPaint);

    // Detached top ellipse
    final detachedPath = Path()..addOval(detachedEllipse);
    drawDashedPath(canvas, detachedPath, borderPaint);

    // Bottom arc (front half only)
    final bottomArcPath = Path()
      ..moveTo(inset, bodyBottom)
      ..arcTo(bottomEllipse, math.pi, -math.pi, false);
    drawDashedPath(canvas, bottomArcPath, borderPaint);
  }
}

class RoundedRectangleNodePainter extends NodePainter {
  const RoundedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final borderRadius = size.height * 0.2;
    final rect = RRect.fromLTRBR(
      style.borderWidth / 2,
      style.borderWidth / 2,
      size.width - (style.borderWidth / 2),
      size.height - (style.borderWidth / 2),
      Radius.circular(borderRadius),
    );

    // Draw background
    canvas.drawRRect(rect, createBackgroundPaint());

    // Draw border
    final path = Path()..addRRect(rect);
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class TriangleNodePainter extends NodePainter {
  const TriangleNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final path = Path()
      ..moveTo(size.width / 2, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class DocumentNodePainter extends NodePainter {
  const DocumentNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveHeight = math.min(size.height * 0.3, 10);

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, size.height - waveHeight - inset);

    // Einzige, durchgehende Welle unten
    final startX = size.width - inset;
    final endX = inset;
    final waveY = size.height - inset;

    // Kontrolle der Wellenform
    final controlPoint1 = Offset(startX * 0.66, waveY + waveHeight);
    final controlPoint2 = Offset(startX * 0.33, waveY - waveHeight);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endX,
      waveY,
    );

    path.lineTo(inset, size.height - waveHeight - inset);
    path.close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class TaggedDocumentNodePainter extends NodePainter {
  const TaggedDocumentNodePainter({
    required super.style,
    required super.scaleFactor,
    this.tagOffsetFactor = 0.10, // Abstand zur Ecke in Breite-Anteilen
    this.minTagOffsetPx = 6.0,
    this.samples = 64,           // Auflösung für Punktsuche auf der Bezier
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

    final p0 = Offset(startX, size.height - waveHeight - inset); // Start der Welle (rechts)
    final p1 = Offset(startX * 0.66, waveY + waveHeight);
    final p2 = Offset(startX * 0.33, waveY - waveHeight);
    final p3 = Offset(endX,          waveY);

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
    final tagOffset = math.max(rectWidth * tagOffsetFactor, minTagOffsetPx * scaleFactor);
    final innerPad = math.max(1.0, style.borderWidth * 0.5);

    final rightX = size.width - inset;
    final desiredX = rightX - tagOffset; // x-Position auf der Welle links neben der Ecke

    // Punkt auf der Bezier suchen, dessen x in etwa desiredX ist
    final startOnWave = _pointOnCubicAtX(
      p0, p1, p2, p3,
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
    canvas.drawLine(
      Offset(startOnWave.dx, startOnWave.dy),
      end,
      tagPaint,
    );
  }

  /// Grobe Suche entlang der kubischen Bezier (monoton fallendes x in deinem Fall).
  /// Gibt den Punkt zurück, dessen x am nächsten bei desiredX liegt.
  Offset _pointOnCubicAtX(
      Offset p0, Offset p1, Offset p2, Offset p3, double desiredX, {int samples = 64}
      ) {
    var prev = p0;

    for (var i = 1; i <= samples; i++) {
      final t = i / samples;
      final pt = _cubicPoint(p0, p1, p2, p3, t);

      // Wir suchen die Stelle, wo x von >desiredX auf <=desiredX geht
      if ((prev.dx >= desiredX && pt.dx <= desiredX) ||
          i == samples) {
        // Linear zwischen prev und pt interpolieren für bessere Näherung
        final denom = (prev.dx - pt.dx);
        final local =
        denom.abs() < 1e-6 ? 0.0 : ((prev.dx - desiredX) / denom).clamp(0.0, 1.0);
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

class LinedDocumentNodePainter extends NodePainter {
  const LinedDocumentNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveHeight = math.min(size.height * 0.3, 10);

    // Dokument-Pfad (oben/seitlich gerade, unten eine Welle)
    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, size.height - waveHeight - inset);

    final startX = size.width - inset;
    final endX = inset;
    final waveY = size.height - inset;

    // sanfte, durchgehende Welle unten
    final controlPoint1 = Offset(startX * 0.66, waveY + waveHeight);
    final controlPoint2 = Offset(startX * 0.33, waveY - waveHeight);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endX,
      waveY,
    );

    path
      ..lineTo(inset, size.height - waveHeight - inset)
      ..close();

    // Hintergrund + Rand
    canvas.drawPath(path, createBackgroundPaint());
    drawDashedPath(canvas, path, createBorderPaint());

    // ===============================
    // Vertikale Innenlinie (linke Margin)
    // ===============================
    // Abstand der Innenlinie von der linken Kante:
    final innerGap = math.max(6.0 * scaleFactor, style.borderWidth * 2);
    final innerX = inset + innerGap;

    // solide, schlanker Strich für die Innenlinie
    final innerLinePaint = Paint()
      ..color = style.borderColor
      ..strokeWidth = math.max(1.0, style.borderWidth * 0.75)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Linie von oben bis zum Wellenbeginn ziehen
    final lineTop = Offset(innerX, inset);
    final lineBottom = Offset(innerX, waveY); // bis ganz unten
    canvas.drawLine(lineTop, lineBottom, innerLinePaint);
  }
}

class MultipleDocumentNodePainter extends NodePainter {
  const MultipleDocumentNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveHeight = size.height * 0.1;

    final backgroundPaint = createBackgroundPaint();
    final borderPaint = createBorderPaint();

    // Optional: leicht transparent für hintere Seiten
    final fadedBackgroundPaint = Paint()
      ..color = style.backgroundColor.withValues(alpha: 1.0)
      ..style = PaintingStyle.fill;
    final fadedBorderPaint = Paint()
      ..color = style.borderColor.withValues(alpha: 0.5)
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke;

    // Verschiebung pro Ebene
    const dx = 6.0;
    const dy = -6.0;

    // Zeichne von hinten nach vorne
    for (int i = 2; i >= 0; i--) {
      final offset = Offset(i * dx, i * dy);

      final path = Path()
        ..moveTo(inset + offset.dx, inset + offset.dy)
        ..lineTo(size.width - inset + offset.dx, inset + offset.dy)
        ..lineTo(
          size.width - inset + offset.dx,
          size.height - waveHeight - inset + offset.dy,
        );

      // Untere Welle (eine Bezier-Welle)
      final startX = size.width - inset + offset.dx;
      final endX = inset + offset.dx;
      final waveY = size.height - inset + offset.dy;

      final controlPoint1 = Offset(startX * 0.66, waveY + waveHeight);
      final controlPoint2 = Offset(startX * 0.33, waveY - waveHeight);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        endX,
        waveY,
      );

      path
        ..lineTo(
          inset + offset.dx,
          size.height - waveHeight - inset + offset.dy,
        )
        ..close();

      // Paint (hintere Pfade transparenter)
      final bg = (i < 2) ? fadedBackgroundPaint : backgroundPaint;
      final border = (i < 2) ? fadedBorderPaint : borderPaint;

      canvas.drawPath(path, bg);
      drawDashedPath(canvas, path, border);
    }
  }
}

class TrapezoidNodePainter extends NodePainter {
  const TrapezoidNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final sideInset = size.width * 0.2;

    final path = Path()
      ..moveTo(sideInset + inset, inset)
      ..lineTo(size.width - sideInset - inset, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class TrapezoidTopNodePainter extends NodePainter {
  const TrapezoidTopNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final sideInset = size.width * 0.2; // bestimmt die Kürze der unteren Kante

    final path = Path()
    // Oben: lange Kante über volle Breite
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
    // Unten: kürzere Kante, nach innen versetzt
      ..lineTo(size.width - sideInset - inset, size.height - inset)
      ..lineTo(sideInset + inset, size.height - inset)
      ..close();

    // Hintergrund
    canvas.drawPath(path, createBackgroundPaint());
    // Rand (ggf. gestrichelt)
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class SmallCircleNodePainter extends NodePainter {
  const SmallCircleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (math.min(size.width, size.height) * 0.3) - (style.borderWidth / 2);

    // Draw background
    canvas.drawCircle(center, radius, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    drawDashedPath(canvas, path, borderPaint);
  }
}

class DoubleCircleNodePainter extends NodePainter {
  const DoubleCircleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius =
        (math.min(size.width, size.height) / 2) - (style.borderWidth / 2);
    final innerRadius = outerRadius * 0.7;

    // Draw background (outer circle)
    canvas.drawCircle(center, outerRadius, createBackgroundPaint());

    // Draw borders
    final borderPaint = createBorderPaint();
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius));
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius));

    drawDashedPath(canvas, outerPath, borderPaint);
    drawDashedPath(canvas, innerPath, borderPaint);
  }
}

class FramedRectangleNodePainter extends NodePainter {
  const FramedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final frameInset = size.width * 0.1;

    final outerRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      size.height - (inset * 2),
    );
    final innerRect = Rect.fromLTWH(
      frameInset + inset,
      inset,
      size.width - (frameInset * 2) - (inset * 2),
      size.height - (inset * 2),
    );

    // Draw background
    canvas.drawRect(outerRect, createBackgroundPaint());

    // Draw borders
    final borderPaint = createBorderPaint();
    final outerPath = Path()..addRect(outerRect);
    final innerPath = Path()..addRect(innerRect);

    drawDashedPath(canvas, outerPath, borderPaint);
    drawDashedPath(canvas, innerPath, borderPaint);
  }
}

class NotchedRectangleNodePainter extends NodePainter {
  const NotchedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final notchSize = size.height * 0.15;

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - notchSize - inset, inset)
      ..lineTo(size.width - inset, notchSize + inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class NotchedPentagonNodePainter extends NodePainter {
  const NotchedPentagonNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Kerbentiefe: an die Node-Größe angepasst und begrenzt
    final baseNotch = size.height * 0.15;
    final notchMax  = math.min(size.height, size.width) * 0.45;
    final notchSize = baseNotch.clamp(0.0, notchMax);

    // Punkte:
    // TL notch innen, TR notch innen, TR notch point, BR, BL, LL notch point
    final topLeftInner   = Offset(inset + notchSize, inset);
    final topRightInner  = Offset(size.width - notchSize - inset, inset);
    final topRightNotch  = Offset(size.width - inset, inset + notchSize);
    final bottomRight    = Offset(size.width - inset, size.height - inset);
    final bottomLeft     = Offset(inset, size.height - inset);
    final topLeftNotch   = Offset(inset, inset + notchSize);

    final path = Path()
      ..moveTo(topLeftInner.dx, topLeftInner.dy)       // oben: nach der linken Kerbe
      ..lineTo(topRightInner.dx, topRightInner.dy)     // obere Kante
      ..lineTo(topRightNotch.dx, topRightNotch.dy)     // rechte Kerbe
      ..lineTo(bottomRight.dx, bottomRight.dy)         // rechte Seite runter
      ..lineTo(bottomLeft.dx, bottomLeft.dy)           // unten rüber
      ..lineTo(topLeftNotch.dx, topLeftNotch.dy)       // linke Seite hoch bis Kerbe
      ..lineTo(topLeftInner.dx, topLeftInner.dy)       // linke Kerbe schließen
      ..close();

    // Füllung
    canvas.drawPath(path, createBackgroundPaint());

    // Kontur (ggf. gestrichelt)
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

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

class LeanRightNodePainter extends NodePainter {
  const LeanRightNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final leanOffset = size.width * 0.2;

    final path = Path()
      ..moveTo(leanOffset + inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - leanOffset - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class LeanLeftNodePainter extends NodePainter {
  const LeanLeftNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final leanOffset = size.width * 0.2;

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - leanOffset - inset, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(leanOffset + inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class HorizontalCylinderNodePainter extends NodePainter {
  const HorizontalCylinderNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final sideWidth = size.width * 0.2;

    // Body (mittlerer Teil)
    final bodyRect = Rect.fromLTWH(
      sideWidth / 2,
      inset,
      size.width - sideWidth - inset,
      size.height - (inset * 2),
    );

    // Ellipsen (Kappen)
    final leftEllipse = Rect.fromLTWH(
      inset,
      inset,
      sideWidth,
      size.height - (inset * 2),
    );
    final rightEllipse = Rect.fromLTWH(
      size.width - sideWidth - inset,
      inset,
      sideWidth,
      size.height - (inset * 2),
    );

    // === Füllung: Body + rechte Kappe ===
    canvas.drawRect(bodyRect, createBackgroundPaint());
    canvas.drawOval(rightEllipse, createBackgroundPaint());

    // === NEU: Füllung der linken Halbellipse ===
    final cx = leftEllipse.center.dx;
    final leftHalfFill = Path()
    // Top-Center der Ellipse
      ..moveTo(cx, leftEllipse.top)
    // Linke Halbellipse: oben -> unten
      ..arcTo(
        leftEllipse,
        -math.pi / 2, // Start oben
        -math.pi,     // über die linke Hälfte nach unten
        false,
      )
    // zurück zum Start entlang der Center-Linie
      ..lineTo(cx, leftEllipse.top)
      ..close();

    canvas.drawPath(leftHalfFill, createBackgroundPaint());

    // === Outline ===
    final borderPaint = createBorderPaint();

    // Obere/untere Kante des Bodys
    canvas.drawLine(
      Offset(sideWidth / 2, inset),
      Offset(size.width - sideWidth / 2, inset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(sideWidth / 2, size.height - inset),
      Offset(size.width - sideWidth / 2, size.height - inset),
      borderPaint,
    );

    // Rechte Ellipse: kompletter Umriss
    final rightPath = Path()..addOval(rightEllipse);
    drawDashedPath(canvas, rightPath, borderPaint);

    // Linke Ellipse: nur die äußere Halbellipse als Kontur
    final leftArcPath = Path()
      ..moveTo(cx, leftEllipse.top)
      ..arcTo(
        leftEllipse,
        -math.pi / 2, // Start oben
        -math.pi,     // linke Hälfte
        false,
      );
    drawDashedPath(canvas, leftArcPath, borderPaint);
  }
}

class DividedRectangleNodePainter extends NodePainter {
  const DividedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      size.height - (inset * 2),
    );
    final dividerY = size.height * 0.1;

    // Draw background
    canvas.drawRect(rect, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, borderPaint);

    // Draw divider line
    canvas.drawLine(
      Offset(inset, dividerY),
      Offset(size.width - inset, dividerY),
      borderPaint,
    );
  }
}

class InternalStorageNodePainter extends NodePainter {
  const InternalStorageNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      size.height - (inset * 2),
    );
    final dividerY = size.height * 0.1;
    final dividerX = size.height * 0.1;

    // Draw background
    canvas.drawRect(rect, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, borderPaint);

    // Draw vertical divider line
    canvas.drawLine(
      Offset(inset, dividerY),
      Offset(size.width - inset, dividerY),
      borderPaint,
    );

    // Draw horizontal divider line
    canvas.drawLine(
      Offset(dividerX, inset),
      Offset(dividerX, size.height - inset),
      borderPaint,
    );
  }
}

class FilledCircleNodePainter extends NodePainter {
  const FilledCircleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (math.min(size.width, size.height) / 2) - (style.borderWidth / 2);

    // Draw filled circle (background color is the fill)
    canvas.drawCircle(center, radius, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    drawDashedPath(canvas, path, borderPaint);
  }
}

class LinedRectangleNodePainter extends NodePainter {
  const LinedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      size.height - (inset * 2),
    );
    final lineSpacing = size.width / 10;

    // Draw background
    canvas.drawRect(rect, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, borderPaint);

    // Draw vertical lines
    final linePaint = Paint()
      ..color = style.borderColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (
      var x = inset + lineSpacing;
      x < size.width - inset;
      x += lineSpacing
    ) {
      canvas.drawLine(
        Offset(x, inset),
        Offset(x, size.height - inset),
        linePaint,
      );
    }
  }
}

class FlippedTriangleNodePainter extends NodePainter {
  const FlippedTriangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final path = Path()
      ..moveTo(size.width / 2, size.height - inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(inset, inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class SlopedRectangleNodePainter extends NodePainter {
  const SlopedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final slopeHeight = size.height * 0.3;

    final path = Path()
      ..moveTo(inset, slopeHeight + inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class StackedRectangleNodePainter extends NodePainter {
  const StackedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
    this.sizeFactor = 0.9,     // 90% der verfügbaren Fläche
    this.shiftFactor = 0.1,   // kleiner Versatz (4% der kleineren Kante)
  });

  /// Anteil der Node-Fläche, den jede Box einnimmt (Breite & Höhe)
  final double sizeFactor;

  /// Relativer Versatz der hinteren Boxen (bezogen auf min(contentW, contentH))
  final double shiftFactor;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Verfügbare Fläche abzüglich Rand
    final contentW = math.max(0.0, size.width  - inset * 2);
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
    final bgMid   = Paint()
      ..color = style.backgroundColor.withValues(alpha:0.85)
      ..style = PaintingStyle.fill;
    final bgBack  = Paint()
      ..color = style.backgroundColor.withValues(alpha:0.7)
      ..style = PaintingStyle.fill;

    final borderFront = createBorderPaint();
    final borderMid   = Paint()
      ..color = style.borderColor.withValues(alpha:0.9)
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke;
    final borderBack  = Paint()
      ..color = style.borderColor.withValues(alpha:0.75)
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
    final contentW = math.max(0.0, size.width  - 2 * inset);
    final contentH = math.max(0.0, size.height - 2 * inset);

    // Zielgröße: 80% Breite/Höhe
    final boxW = contentW * boxFactor;
    final boxH = contentH * boxFactor;

    // Grund-Position: zentriert
    double left   = inset + (contentW - boxW) / 2;
    final top     = inset + (contentH - boxH) / 2;
    double rightX = left + boxW;
    final bottom  = top + boxH;

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
      final maxShiftLeft = rightX - inset - boxW; // wie weit können wir nach links gehen
      final shift = math.min(extra, maxShiftLeft);
      left   -= shift;
      rightX -= shift;
    }

    // Falls immer noch zu groß (extreme Seitenverhältnisse), Radius begrenzen:
    r = math.min(r, (inset + contentW) - rightX);

    // Path: oben links → oben rechts (Boxkante) → Halbkreis nach unten →
    // unten links → schließen
    final path = Path()
      ..moveTo(left, top)          // oben links
      ..lineTo(rightX, top);       // oben rechts (Startpunkt des Halbkreises)

    // Halbkreis (rechts) – Bounding-Rect des Vollkreises
    final circleRect = Rect.fromCircle(center: Offset(rightX, cy), radius: r);

    // Von oben (Startwinkel -90°) nach unten (+90°), positive Sweep (clockwise)
    path.arcTo(
      circleRect,
      -math.pi / 2,  // Start: oben
      math.pi,       // 180° Bogen nach unten
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

class CurvedTrapezoidNodePainter extends NodePainter {
  const CurvedTrapezoidNodePainter({
    required super.style,
    required super.scaleFactor,
    this.boxFactor = 0.8,      // Anteil der verfügbaren Fläche für das Rechteck
    this.spikeFactor = 0.10,   // Länge der linken Spitze relativ zu style.width
    this.minSpikePx = 6.0,     // Mindestlänge der Spitze in px
  });

  final double boxFactor;
  final double spikeFactor;
  final double minSpikePx;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Verfügbare Fläche (innen)
    final contentW = math.max(0.0, size.width  - 2 * inset);
    final contentH = math.max(0.0, size.height - 2 * inset);

    // Boxgröße
    final boxW = contentW * boxFactor;
    final boxH = contentH * boxFactor;

    // Zentrierte Position
    double left   = inset + (contentW - boxW) / 2;
    final top     = inset + (contentH - boxH) / 2;
    double rightX = left + boxW;
    final bottom  = top + boxH;

    // Rechte Halbkreis-Kappe
    double r = boxH / 2.0;
    final cy = (top + bottom) / 2.0;

    // Sicherstellen, dass die Kappe rechts reinpasst
    final maxR = (inset + contentW) - rightX;
    if (r > maxR) {
      final extra = r - maxR;
      final maxShiftLeft = rightX - inset - boxW;
      final shift = math.min(extra, maxShiftLeft);
      left   -= shift;
      rightX -= shift;
    }
    r = math.min(r, (inset + contentW) - rightX);

    // Spike-Länge (links nach außen)
    final styleW = _tryGetStyleWidth() ?? size.width;
    final spikeLen = math.max(styleW * spikeFactor, minSpikePx * scaleFactor);

    // Pfad: oben links → oben rechts → Halbkreis → unten links → Spitze → oben links
    final path = Path()
      ..moveTo(left, top)          // oben links
      ..lineTo(rightX, top);       // oben rechts (Start Halbkreis)

    // Halbkreis rechts (oben → unten, 180°)
    final circleRect = Rect.fromCircle(center: Offset(rightX, cy), radius: r);
    path.arcTo(circleRect, -math.pi / 2, math.pi, false);

    // Unterkante zurück nach links-unten
    path.lineTo(left, bottom);

    // Spitze: von unten links zur mittigen Spitze nach außen, dann hoch zu oben links
    final tip = Offset(left - spikeLen, cy);
    path
      ..lineTo(tip.dx, tip.dy)   // untere Ecke → Spitze
      ..lineTo(left, top)        // Spitze → obere Ecke
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

class BowTieRectangleNodePainter extends NodePainter {
  const BowTieRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
    this.curveDepth = 15.0, // Wie weit die Rundung raus/rein geht
  });

  /// Positiver Wert: größere Auswölbung / Einbuchtung
  final double curveDepth;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    final path = Path();

    // Start oben links
    path.moveTo(inset, inset);

    // Oben gerade Linie
    path.lineTo(size.width - inset, inset);

    // Rechte Seite: flache konkave Rundung
    path.quadraticBezierTo(
      size.width + inset - curveDepth, // Steuerpunkt leicht rechts raus
      size.height / 2, // Mitte
      size.width - inset, // Endpunkt unten rechts
      size.height - inset, // unten rechts
    );

    // Unten gerade Linie zurück
    path.lineTo(inset, size.height - inset);

    // Linke Seite: flache konvexe Rundung
    path.quadraticBezierTo(
      inset - curveDepth, // Steuerpunkt leicht links rein
      size.height / 2, // Mitte
      inset, // Endpunkt oben links
      inset, // zurück zum Start
    );

    path.close();

    // Hintergrund
    canvas.drawPath(path, createBackgroundPaint());

    // Rand
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

class CrossedCircleNodePainter extends NodePainter {
  const CrossedCircleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (math.min(size.width, size.height) / 2) - (style.borderWidth / 2);

    // Draw background
    canvas.drawCircle(center, radius, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    drawDashedPath(canvas, path, borderPaint);

    // Draw cross
    final crossRadius = radius * 0.7;
    canvas.drawLine(
      Offset(center.dx - crossRadius, center.dy - crossRadius),
      Offset(center.dx + crossRadius, center.dy + crossRadius),
      borderPaint,
    );
    canvas.drawLine(
      Offset(center.dx + crossRadius, center.dy - crossRadius),
      Offset(center.dx - crossRadius, center.dy + crossRadius),
      borderPaint,
    );
  }
}

class FlagNodePainter extends NodePainter {
  const FlagNodePainter({
    required super.style,
    required super.scaleFactor,
    this.segments = 64,     // Mehr Segmente für glatte Wellen
    this.ampFactor = 0.12,  // Amplitude relativ zur Höhe
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

class OddNodePainter extends NodePainter {
  const OddNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final centerY = size.height / 2;
    final neckWidth = size.width * 0.6;

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..lineTo((size.width - neckWidth) / 2, centerY)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}

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

class BoltNodePainter extends NodePainter {
  const BoltNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final w = size.height / 2;
    final h = size.height;
    final xOffset = (size.width / 2) - (w/2) ;

    final topTip = Offset(xOffset+w, 0);
    final k1 = Offset(xOffset, h * 0.55);
    final hr1 = Offset(xOffset+(w * 0.65), h * 0.55);
    final k2 = Offset(xOffset, h);
    final k3 = Offset(xOffset +w, h * 0.45);

    final hr2 = Offset(xOffset +(w*0.45), h * 0.45);



    final boltPath = Path()
      ..moveTo(topTip.dx, topTip.dy)
      ..lineTo(k1.dx, k1.dy)
      ..lineTo(hr1.dx, hr1.dy)
      ..lineTo(k2.dx, k2.dy)
      ..lineTo(k3.dx, k3.dy)
      ..lineTo(hr2.dx, hr2.dy)


      ..close();

    // Füllung
    canvas.drawPath(boltPath, createBackgroundPaint());

    // Outline (mit runden Ecken/Kappen für schönere Zacken)
    final outline = createBorderPaint()
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    drawDashedPath(canvas, boltPath, outline);
  }
}

class ForkNodePainter extends NodePainter {
  const ForkNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Basis aus style.width/height, sonst aus size
    final baseW = _tryGetStyleWidth()  ?? size.width;
    final baseH = _tryGetStyleHeight() ?? size.height;

    // Zielmaße: 70% Breite, 35% Höhe
    final targetW = baseW * 0.70;
    final targetH = baseH * 0.35;

    // Zentriert in der verfügbaren Zeichenfläche platzieren
    final left = (size.width  - targetW) / 2 + inset;
    final top  = (size.height - targetH) / 2 + inset;

    // Innenmaß so wählen, dass der Stroke nicht herausragt
    final rectW = math.max(0.0, targetW - style.borderWidth);
    final rectH = math.max(0.0, targetH - style.borderWidth);

    final rect = Rect.fromLTWH(left, top, rectW, rectH);

    // Füllung
    canvas.drawRect(rect, createBackgroundPaint());

    // Kontur (ggf. gestrichelt)
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, createBorderPaint());
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
}

// =============================================================================
// TEXT SEGMENT TYPES
// =============================================================================

abstract class TextSegment {}

class TextSegmentText extends TextSegment {
  TextSegmentText(this.text);

  final String text;
}

class TextSegmentIcon extends TextSegment {
  TextSegmentIcon(this.iconData);

  final IconData iconData;
}
