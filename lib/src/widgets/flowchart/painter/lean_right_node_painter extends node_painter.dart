import 'node_painter.dart';

class LeanRightNodePainter extends NodePainter {
  const LeanRightNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final leanOffset = size.width * 0.2;

    final path = Path()
      ..moveTo(leanOffset + inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - leanOffset - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
