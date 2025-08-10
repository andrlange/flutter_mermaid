import 'dart:math' as math;
import 'node_painter.dart';

class ForkNodePainter extends NodePainter {
  const ForkNodePainter({required super.style, required super.scaleFactor});

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    // Basis aus style.width/height, sonst aus size
    final baseW = _tryGetStyleWidth() ?? size.width;
    final baseH = _tryGetStyleHeight() ?? size.height;

    // Zielmaße: 70% Breite, 35% Höhe
    final targetW = baseW * 0.70;
    final targetH = baseH * 0.35;

    // Zentriert in der verfügbaren Zeichenfläche platzieren
    final left = (size.width - targetW) / 2 + inset;
    final top = (size.height - targetH) / 2 + inset;

    // Innenmaß so wählen, dass der Stroke nicht herausragt
    final rectW = math.max(0.0, targetW - style.borderWidth);
    final rectH = math.max(0.0, targetH - style.borderWidth);

    final rect = Rect.fromLTWH(left, top, rectW, rectH);

    // Füllung
    canvas.drawRect(rect, createBackgroundPaint());

    // Kontur (ggf. gestrichelt)
    final path = Path()..addRect(rect);
    drawDashedPath(canvas, path, createBorderPaint());
  }

  double? _tryGetStyleWidth() {
    try {
      final v = (style as dynamic).width;
      if (v is double && v > 0) return v;
    } catch (_) {}
    return null;
  }

  double? _tryGetStyleHeight() {
    try {
      final v = (style as dynamic).height;
      if (v is double && v > 0) return v;
    } catch (_) {}
    return null;
  }
}

// =============================================================================
// TEXT SEGMENT TYPES
// =============================================================================

abstract class TextSegment {}

class TextSegmentText extends TextSegment {
  TextSegmentText(this.text);

  final String text;
}

class TextSegmentIcon extends TextSegment {
  TextSegmentIcon(this.iconData);

  final IconData iconData;
}
