// =============================================================================
// CROSSED CIRCLE NODE WIDGET
// =============================================================================

import 'base_node_widget.dart';
import 'painter/crossed_circle_node_painter.dart';
export 'styles/node_styles.dart';

class CrossedCircleNode extends StatelessWidget {
  const CrossedCircleNode({
    super.key,
    this.text = '',
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
      painter: CrossedCircleNodePainter(style: style, scaleFactor: scaleFactor),
    );
  }
}