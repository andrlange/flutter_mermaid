// =============================================================================
// LEAN RIGHT NODE WIDGET
// =============================================================================

import 'base_node_widget.dart';
import 'painter/lean_right_node_painter extends node_painter.dart';
export 'styles/node_styles.dart';

class LeanRightNode extends StatelessWidget {
  const LeanRightNode({
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
      painter: LeanRightNodePainter(style: style, scaleFactor: scaleFactor),
    );
  }
}