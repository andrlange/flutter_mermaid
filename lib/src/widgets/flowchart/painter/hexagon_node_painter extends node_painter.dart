import 'node_painter.dart';

class HexagonNodePainter extends NodePainter {
  const HexagonNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    //final centerX = size.width / 2;
    final centerY = size.height / 2;
    final inset = style.borderWidth / 2;
    final sideWidth = size.width * 0.2; // 20% for angled sides

    final path = Path()
      ..moveTo(sideWidth + inset, inset)
      ..lineTo(size.width - sideWidth - inset, inset)
      ..lineTo(size.width - inset, centerY)
      ..lineTo(size.width - sideWidth - inset, size.height - inset)
      ..lineTo(sideWidth + inset, size.height - inset)
      ..lineTo(inset, centerY)
      ..close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
