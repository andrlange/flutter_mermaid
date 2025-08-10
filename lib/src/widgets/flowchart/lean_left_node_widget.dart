// =============================================================================
// LEAN LEFT NODE WIDGET
// =============================================================================

import 'base_node_widget.dart';
import 'painter/lean_left_node_painter extends node_painter.dart';
export 'styles/node_styles.dart';

class LeanLeftNode extends StatelessWidget {
  const LeanLeftNode({
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
      painter: LeanLeftNodePainter(style: style, scaleFactor: scaleFactor),
    );
  }
}