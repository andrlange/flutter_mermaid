// =============================================================================
// STADIUM NODE WIDGET
// =============================================================================

import 'package:flutter/material.dart';

import 'base_node_widget.dart';
export 'styles/node_styles.dart';

class StadiumNode extends StatelessWidget {
  const StadiumNode({
    super.key,
    required this.text,
    this.style = const NodeStyle(),
    this.scaleFactor = 1.0,
    this.onTap,
  });

  final String text;
  final NodeStyle style;
  final double scaleFactor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BaseNodeWidget(
      text: text,
      style: style,
      scaleFactor: scaleFactor,
      onTap: onTap,
      painter: StadiumNodePainter(style: style, scaleFactor: scaleFactor),
    );
  }
}