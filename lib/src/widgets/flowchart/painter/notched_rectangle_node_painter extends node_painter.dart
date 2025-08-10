import 'node_painter.dart';

class NotchedRectangleNodePainter extends NodePainter {
  const NotchedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final notchSize = size.height * 0.15;

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - notchSize - inset, inset)
      ..lineTo(size.width - inset, notchSize + inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
