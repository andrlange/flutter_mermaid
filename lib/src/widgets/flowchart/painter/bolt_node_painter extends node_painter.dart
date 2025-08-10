import 'node_painter.dart';

class BoltNodePainter extends NodePainter {
  const BoltNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final w = size.height / 2;
    final h = size.height;
    final xOffset = (size.width / 2) - (w / 2);

    final topTip = Offset(xOffset + w, 0);
    final k1 = Offset(xOffset, h * 0.55);
    final hr1 = Offset(xOffset + (w * 0.65), h * 0.55);
    final k2 = Offset(xOffset, h);
    final k3 = Offset(xOffset + w, h * 0.45);

    final hr2 = Offset(xOffset + (w * 0.45), h * 0.45);

    final boltPath = Path()
      ..moveTo(topTip.dx, topTip.dy)
      ..lineTo(k1.dx, k1.dy)
      ..lineTo(hr1.dx, hr1.dy)
      ..lineTo(k2.dx, k2.dy)
      ..lineTo(k3.dx, k3.dy)
      ..lineTo(hr2.dx, hr2.dy)
      ..close();

    // Füllung
    canvas.drawPath(boltPath, createBackgroundPaint());

    // Outline (mit runden Ecken/Kappen für schönere Zacken)
    final outline = createBorderPaint()
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    drawDashedPath(canvas, boltPath, outline);
  }
}
