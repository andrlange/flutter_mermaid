import 'node_painter.dart';

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
