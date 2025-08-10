import 'node_painter.dart';

class MultipleDocumentNodePainter extends NodePainter {
  const MultipleDocumentNodePainter({
    required super.style,
    required super.scaleFactor,
  });

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;
    final waveHeight = size.height * 0.1;

    final backgroundPaint = createBackgroundPaint();
    final borderPaint = createBorderPaint();

    // Optional: leicht transparent für hintere Seiten
    final fadedBackgroundPaint = Paint()
      ..color = style.backgroundColor.withValues(alpha: 1.0)
      ..style = PaintingStyle.fill;
    final fadedBorderPaint = Paint()
      ..color = style.borderColor.withValues(alpha: 0.5)
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke;

    // Verschiebung pro Ebene
    const dx = 6.0;
    const dy = -6.0;

    // Zeichne von hinten nach vorne
    for (int i = 2; i >= 0; i--) {
      final offset = Offset(i * dx, i * dy);

      final path = Path()
        ..moveTo(inset + offset.dx, inset + offset.dy)
        ..lineTo(size.width - inset + offset.dx, inset + offset.dy)
        ..lineTo(
          size.width - inset + offset.dx,
          size.height - waveHeight - inset + offset.dy,
        );

      // Untere Welle (eine Bezier-Welle)
      final startX = size.width - inset + offset.dx;
      final endX = inset + offset.dx;
      final waveY = size.height - inset + offset.dy;

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
        ..lineTo(
          inset + offset.dx,
          size.height - waveHeight - inset + offset.dy,
        )
        ..close();

      // Paint (hintere Pfade transparenter)
      final bg = (i < 2) ? fadedBackgroundPaint : backgroundPaint;
      final border = (i < 2) ? fadedBorderPaint : borderPaint;

      canvas.drawPath(path, bg);
      drawDashedPath(canvas, path, border);
    }
  }
}
