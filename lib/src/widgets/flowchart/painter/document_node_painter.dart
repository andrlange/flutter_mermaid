import 'dart:math' as math;
import 'node_painter.dart';

class DocumentNodePainter extends NodePainter {
  const DocumentNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveHeight = math.min(size.height * 0.3, 10);

    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, size.height - waveHeight - inset);

    // Einzige, durchgehende Welle unten
    final startX = size.width - inset;
    final endX = inset;
    final waveY = size.height - inset;

    // Kontrolle der Wellenform
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

    path.lineTo(inset, size.height - waveHeight - inset);
    path.close();

    // Draw background
    canvas.drawPath(path, createBackgroundPaint());

    // Draw border
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
