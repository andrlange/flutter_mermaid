import 'node_painter.dart';

class LeanLeftNodePainter extends NodePainter {
  const LeanLeftNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final leanOffset = size.width * 0.2;

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - leanOffset - inset, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(leanOffset + inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
