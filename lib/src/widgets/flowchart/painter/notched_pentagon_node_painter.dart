import 'dart:math' as math;
import 'node_painter.dart';

class NotchedPentagonNodePainter extends NodePainter {
  const NotchedPentagonNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Kerbentiefe: an die Node-Größe angepasst und begrenzt
    final baseNotch = size.height * 0.15;
    final notchMax = math.min(size.height, size.width) * 0.45;
    final notchSize = baseNotch.clamp(0.0, notchMax);

    // Punkte:
    // TL notch innen, TR notch innen, TR notch point, BR, BL, LL notch point
    final topLeftInner = Offset(inset + notchSize, inset);
    final topRightInner = Offset(size.width - notchSize - inset, inset);
    final topRightNotch = Offset(size.width - inset, inset + notchSize);
    final bottomRight = Offset(size.width - inset, size.height - inset);
    final bottomLeft = Offset(inset, size.height - inset);
    final topLeftNotch = Offset(inset, inset + notchSize);

    final path = Path()
      ..moveTo(topLeftInner.dx, topLeftInner.dy) // oben: nach der linken Kerbe
      ..lineTo(topRightInner.dx, topRightInner.dy) // obere Kante
      ..lineTo(topRightNotch.dx, topRightNotch.dy) // rechte Kerbe
      ..lineTo(bottomRight.dx, bottomRight.dy) // rechte Seite runter
      ..lineTo(bottomLeft.dx, bottomLeft.dy) // unten rüber
      ..lineTo(topLeftNotch.dx, topLeftNotch.dy) // linke Seite hoch bis Kerbe
      ..lineTo(topLeftInner.dx, topLeftInner.dy) // linke Kerbe schließen
      ..close();

    // Füllung
    canvas.drawPath(path, createBackgroundPaint());

    // Kontur (ggf. gestrichelt)
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
