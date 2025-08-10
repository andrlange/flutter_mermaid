import 'dart:math' as math;
import 'node_painter.dart';

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
