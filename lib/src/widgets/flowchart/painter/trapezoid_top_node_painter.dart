import 'node_painter.dart';

class TrapezoidTopNodePainter extends NodePainter {
  const TrapezoidTopNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final sideInset = size.width * 0.2; // bestimmt die Kürze der unteren Kante

    final path = Path()
      // Oben: lange Kante über volle Breite
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
      // Unten: kürzere Kante, nach innen versetzt
      ..lineTo(size.width - sideInset - inset, size.height - inset)
      ..lineTo(sideInset + inset, size.height - inset)
      ..close();

    // Hintergrund
    canvas.drawPath(path, createBackgroundPaint());
    // Rand (ggf. gestrichelt)
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
