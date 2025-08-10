import 'node_painter.dart';

class LinedRectangleNodePainter extends NodePainter {
  const LinedRectangleNodePainter({
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
    final lineSpacing = size.width / 10;

    // Draw background
    canvas.drawRect(rect, createBackgroundPaint());

    // Draw border
    final borderPaint = createBorderPaint();
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, borderPaint);

    // Draw vertical lines
    final linePaint = Paint()
      ..color = style.borderColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (
      var x = inset + lineSpacing;
      x < size.width - inset;
      x += lineSpacing
    ) {
      canvas.drawLine(
        Offset(x, inset),
        Offset(x, size.height - inset),
        linePaint,
      );
    }
  }
}
