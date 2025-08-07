import 'package:flutter/material.dart';

class FlowchartNodeStyle {
  const FlowchartNodeStyle({
    this.strokeColor = Colors.white10,
    this.fillColor = Colors.white30,
    this.color = Colors.black54,
    this.strokeWidth = 2.0,
    this.strokeDasharray = 0,
    this.hyperlink = '',
  });

  final Color strokeColor;
  final Color fillColor;
  final Color color;
  final double strokeWidth;
  final int strokeDasharray;
  final String hyperlink;

  @override
  String toString() {
    return 'FlowchartNodeStyle(strokeColor: $strokeColor, fillColor: $fillColor, color: $color, strokeWidth: $strokeWidth, strokeDasharray: $strokeDasharray, hyperlink:)';
  }
}
