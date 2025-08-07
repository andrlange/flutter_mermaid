import 'package:flutter/material.dart';

enum EdgeArrowType { none, arrow, circle, cross }
enum EdgeStrokeType { none, normal, dotted, thick }
enum EdgeAnimationType { none, slow, fast }

class FlowchartEdgeStyle {
  const FlowchartEdgeStyle({
    this.edgeColor = Colors.black87,
    this.startArrow = EdgeArrowType.none,
    this.endArrow = EdgeArrowType.none,
    this.strokeType = EdgeStrokeType.normal,
    this.animationType = EdgeAnimationType.none,
  });

  final Color edgeColor;
  final EdgeArrowType startArrow;
  final EdgeArrowType endArrow;
  final EdgeStrokeType strokeType;
  final EdgeAnimationType animationType;


  @override
  String toString() {
    return 'FlowchartEdgeStyle(edgeColor: $edgeColor, startArrow: $startArrow, endArrow: $endArrow, strokeType: $strokeType, animationType: $animationType)';
  }
}
