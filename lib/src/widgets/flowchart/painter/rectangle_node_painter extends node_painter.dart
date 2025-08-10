import 'node_painter.dart';

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
