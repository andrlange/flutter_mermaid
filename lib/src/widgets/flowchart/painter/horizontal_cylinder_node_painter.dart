import 'dart:math' as math;
import 'node_painter.dart';

class HorizontalCylinderNodePainter extends NodePainter {
  const HorizontalCylinderNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final sideWidth = size.width * 0.2;

    // Body (mittlerer Teil)
    final bodyRect = Rect.fromLTWH(
      sideWidth / 2,
      inset,
      size.width - sideWidth - inset,
      size.height - (inset * 2),
    );

    // Ellipsen (Kappen)
    final leftEllipse = Rect.fromLTWH(
      inset,
      inset,
      sideWidth,
      size.height - (inset * 2),
    );
    final rightEllipse = Rect.fromLTWH(
      size.width - sideWidth - inset,
      inset,
      sideWidth,
      size.height - (inset * 2),
    );

    // === Füllung: Body + rechte Kappe ===
    canvas.drawRect(bodyRect, createBackgroundPaint());
    canvas.drawOval(rightEllipse, createBackgroundPaint());

    // === NEU: Füllung der linken Halbellipse ===
    final cx = leftEllipse.center.dx;
    final leftHalfFill = Path()
      // Top-Center der Ellipse
      ..moveTo(cx, leftEllipse.top)
      // Linke Halbellipse: oben -> unten
      ..arcTo(
        leftEllipse,
        -math.pi / 2, // Start oben
        -math.pi, // über die linke Hälfte nach unten
        false,
      )
      // zurück zum Start entlang der Center-Linie
      ..lineTo(cx, leftEllipse.top)
      ..close();

    canvas.drawPath(leftHalfFill, createBackgroundPaint());

    // === Outline ===
    final borderPaint = createBorderPaint();

    // Obere/untere Kante des Bodys
    canvas.drawLine(
      Offset(sideWidth / 2, inset),
      Offset(size.width - sideWidth / 2, inset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(sideWidth / 2, size.height - inset),
      Offset(size.width - sideWidth / 2, size.height - inset),
      borderPaint,
    );

    // Rechte Ellipse: kompletter Umriss
    final rightPath = Path()..addOval(rightEllipse);
    drawDashedPath(canvas, rightPath, borderPaint);

    // Linke Ellipse: nur die äußere Halbellipse als Kontur
    final leftArcPath = Path()
      ..moveTo(cx, leftEllipse.top)
      ..arcTo(
        leftEllipse,
        -math.pi / 2, // Start oben
        -math.pi, // linke Hälfte
        false,
      );
    drawDashedPath(canvas, leftArcPath, borderPaint);
  }
}
