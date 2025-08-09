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

    // Main cylinder body
    final bodyRect = Rect.fromLTWH(
      sideWidth / 2,
      inset,
      size.width - sideWidth - inset,
      size.height - (inset * 2),
    );

    // Left ellipse
    final leftEllipse = Rect.fromLTWH(
      inset,
      inset,
      sideWidth,
      size.height - (inset * 2),
    );

    // Right ellipse
    final rightEllipse = Rect.fromLTWH(
      size.width - sideWidth - inset,
      inset,
      sideWidth,
      size.height - (inset * 2),
    );

    // Draw background
    canvas.drawRect(bodyRect, createBackgroundPaint());
    canvas.drawOval(leftEllipse, createBackgroundPaint());
    canvas.drawOval(rightEllipse, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();

    // Body top and bottom
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

    // Left and right ellipses
    final leftPath = Path()..addOval(leftEllipse);
    final rightPath = Path()..addOval(rightEllipse);
    drawDashedPath(canvas, leftPath, borderPaint);
    drawDashedPath(canvas, rightPath, borderPaint);
  }
}

class CurvedTrapezoidNodePainter extends NodePainter {
  const CurvedTrapezoidNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final topWidth = size.width * 0.8;
    //final bottomWidth = size.width - (inset * 2);
    final topStart = (size.width - topWidth) / 2;

    final path = Path()
      ..moveTo(topStart, inset)
      ..lineTo(topStart + topWidth, inset);

    // Curved right side
    path.quadraticBezierTo(
      size.width - inset,
      size.height * 0.3,
      size.width - inset,
      size.height - inset,
    );

    path.lineTo(inset, size.height - inset);

    // Curved left side
    path.quadraticBezierTo(inset, size.height * 0.3, topStart, inset);

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
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
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final stackOffset = size.width * 0.1;

    // Back rectangles (stacked effect)
    final rect1 = Rect.fromLTWH(
      stackOffset + inset,
      inset,
      size.width - stackOffset - (inset * 2),
      size.height - stackOffset - (inset * 2),
    );

    final rect2 = Rect.fromLTWH(
      stackOffset / 2 + inset,
      stackOffset / 2 + inset,
      size.width - stackOffset / 2 - (inset * 2),
      size.height - stackOffset / 2 - (inset * 2),
    );

    final rect3 = Rect.fromLTWH(
      inset,
      stackOffset + inset,
      size.width - (inset * 2),
      size.height - stackOffset - (inset * 2),
    );

    // Draw backgrounds (stacked)
    canvas.drawRect(rect1, createBackgroundPaint());
    canvas.drawRect(rect2, createBackgroundPaint());
    canvas.drawRect(rect3, createBackgroundPaint());

    // Draw borders
    final borderPaint = createBorderPaint();
    drawDashedPath(canvas, Path()..addRect(rect1), borderPaint);
    drawDashedPath(canvas, Path()..addRect(rect2), borderPaint);
    drawDashedPath(canvas, Path()..addRect(rect3), borderPaint);
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
  const FlagNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveWidth = size.width / 6;
    final waveHeight = size.height / 8;

    final path = Path()..moveTo(inset, inset);

    // Top edge with waves
    for (int i = 0; i < 3; i++) {
      final x = (size.width - (inset * 2)) * i / 3 + inset;
      final nextX = (size.width - (inset * 2)) * (i + 1) / 3 + inset;
      final midX = (x + nextX) / 2;
      final y = inset;
      final controlY = (i % 2 == 0) ? y - waveHeight : y + waveHeight;

      path.quadraticBezierTo(midX, controlY, nextX, y);
    }

    path
      ..lineTo(size.width - inset, size.height / 2)
      ..lineTo(size.width - waveWidth - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
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
