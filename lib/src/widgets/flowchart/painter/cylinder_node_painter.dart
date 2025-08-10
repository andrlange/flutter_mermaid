import 'dart:math' as math;
import 'node_painter.dart';

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
