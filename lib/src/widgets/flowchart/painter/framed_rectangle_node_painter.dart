import 'node_painter.dart';

class FramedRectangleNodePainter extends NodePainter {
  const FramedRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final frameInset = size.width * 0.1;

    final outerRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      size.height - (inset * 2),
    );
    final innerRect = Rect.fromLTWH(
      frameInset + inset,
      inset,
      size.width - (frameInset * 2) - (inset * 2),
      size.height - (inset * 2),
    );

    // Draw background
    canvas.drawRect(outerRect, createBackgroundPaint());

    // Draw borders
    final borderPaint = createBorderPaint();
    final outerPath = Path()..addRect(outerRect);
    final innerPath = Path()..addRect(innerRect);

    drawDashedPath(canvas, outerPath, borderPaint);
    drawDashedPath(canvas, innerPath, borderPaint);
  }
}
