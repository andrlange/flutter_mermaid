import 'dart:math' as math;
import 'node_painter.dart';

class LinedDocumentNodePainter extends NodePainter {
  const LinedDocumentNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveHeight = math.min(size.height * 0.3, 10);

    // Dokument-Pfad (oben/seitlich gerade, unten eine Welle)
    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, size.height - waveHeight - inset);

    final startX = size.width - inset;
    final endX = inset;
    final waveY = size.height - inset;

    // sanfte, durchgehende Welle unten
    final controlPoint1 = Offset(startX * 0.66, waveY + waveHeight);
    final controlPoint2 = Offset(startX * 0.33, waveY - waveHeight);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endX,
      waveY,
    );

    path
      ..lineTo(inset, size.height - waveHeight - inset)
      ..close();

    // Hintergrund + Rand
    canvas.drawPath(path, createBackgroundPaint());
    drawDashedPath(canvas, path, createBorderPaint());

    // ===============================
    // Vertikale Innenlinie (linke Margin)
    // ===============================
    // Abstand der Innenlinie von der linken Kante:
    final innerGap = math.max(6.0 * scaleFactor, style.borderWidth * 2);
    final innerX = inset + innerGap;

    // solide, schlanker Strich für die Innenlinie
    final innerLinePaint = Paint()
      ..color = style.borderColor
      ..strokeWidth = math.max(1.0, style.borderWidth * 0.75)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Linie von oben bis zum Wellenbeginn ziehen
    final lineTop = Offset(innerX, inset);
    final lineBottom = Offset(innerX, waveY); // bis ganz unten
    canvas.drawLine(lineTop, lineBottom, innerLinePaint);
  }
}
