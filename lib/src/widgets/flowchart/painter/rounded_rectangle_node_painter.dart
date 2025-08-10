import 'node_painter.dart';

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
