import 'dart:math' as math;
import 'node_painter.dart';

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
