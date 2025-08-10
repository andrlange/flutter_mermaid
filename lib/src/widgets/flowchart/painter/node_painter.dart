// =============================================================================
// BASE NODE PAINTER INTERFACE
// =============================================================================


import 'package:flutter/material.dart';
import '../styles/node_styles.dart';
export 'dart:math';
export 'package:flutter/material.dart';

abstract class NodePainter extends CustomPainter {
  const NodePainter({required this.style, required this.scaleFactor});

  final NodeStyle style;
  final double scaleFactor;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  /// Draw the node shape within the given size
  void drawShape(Canvas canvas, Size size);

  @override
  void paint(Canvas canvas, Size size) {
    drawShape(canvas, size);
  }

  /// Helper method to create paint with border style
  Paint createBorderPaint() {
    final paint = Paint()
      ..color = style.borderColor
      ..strokeWidth = style.borderWidth
      ..style = PaintingStyle.stroke;

    return paint;
  }

  /// Helper method to create background paint
  Paint createBackgroundPaint() {
    return Paint()
      ..color = style.backgroundColor
      ..style = PaintingStyle.fill;
  }

  /// Helper method to draw dashed path
  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    if (!style.isDashed) {
      canvas.drawPath(path, paint);
      return;
    }

    final dashWidth = style.borderWidth * 3;
    final dashSpace = style.borderWidth * 2;

    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      var distance = 0.0;
      var draw = true;

      while (distance < pathMetric.length) {
        final segmentLength = draw ? dashWidth : dashSpace;
        final segment = pathMetric.extractPath(
          distance,
          distance + segmentLength,
        );

        if (draw) {
          canvas.drawPath(segment, paint);
        }

        distance += segmentLength;
        draw = !draw;
      }
    }
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
