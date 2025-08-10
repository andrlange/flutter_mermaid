import 'node_painter.dart';

class DividedRectangleNodePainter extends NodePainter {
  const DividedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      size.height - (inset * 2),
    );
    final dividerY = size.height * 0.1;

    // Draw background
    canvas.drawRect(rect, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, borderPaint);

    // Draw divider line
    canvas.drawLine(
      Offset(inset, dividerY),
      Offset(size.width - inset, dividerY),
      borderPaint,
    );
  }
}
