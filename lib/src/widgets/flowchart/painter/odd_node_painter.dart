import 'node_painter.dart';

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
