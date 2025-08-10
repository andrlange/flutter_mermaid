import 'node_painter.dart';

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
