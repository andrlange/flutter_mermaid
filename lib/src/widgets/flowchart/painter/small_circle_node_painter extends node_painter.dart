import 'dart:math' as math;
import 'node_painter.dart';

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
