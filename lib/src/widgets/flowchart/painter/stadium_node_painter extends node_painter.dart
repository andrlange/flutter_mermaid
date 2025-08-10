import 'node_painter.dart';

class StadiumNodePainter extends NodePainter {
  const StadiumNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final rect = RRect.fromLTRBR(
      style.borderWidth / 2,
      style.borderWidth / 2,
      size.width - (style.borderWidth / 2),
      size.height - (style.borderWidth / 2),
      Radius.circular(size.height / 2),
    );

    // Draw background
    canvas.drawRRect(rect, createBackgroundPaint());

    // Draw border
    final path = Path()..addRRect(rect);
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
