import 'dart:math' as math;
import 'node_painter.dart';

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
