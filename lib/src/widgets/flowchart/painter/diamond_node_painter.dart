import 'node_painter.dart';

class DiamondNodePainter extends NodePainter {
  const DiamondNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    //final halfWidth = (size.width / 2) - (style.borderWidth / 2);
    //final halfHeight = (size.height / 2) - (style.borderWidth / 2);

    final path = Path()
      ..moveTo(centerX, style.borderWidth / 2)
      ..lineTo(size.width - (style.borderWidth / 2), centerY)
      ..lineTo(centerX, size.height - (style.borderWidth / 2))
      ..lineTo(style.borderWidth / 2, centerY)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
