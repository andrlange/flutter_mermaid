import 'node_painter.dart';

class TrapezoidNodePainter extends NodePainter {
  const TrapezoidNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final sideInset = size.width * 0.2;

    final path = Path()
      ..moveTo(sideInset + inset, inset)
      ..lineTo(size.width - sideInset - inset, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
