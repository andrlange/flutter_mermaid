// =============================================================================
// DEMO PAGE
// =============================================================================

import 'package:flutter/material.dart';

import '../src/widgets/flowchart_widgets.dart';

class NodeWidgetDemo extends StatelessWidget {
  const NodeWidgetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mermaid Flowchart Node Widgets', style: TextStyle
          (color: Colors.white),),
        backgroundColor: Colors.blueGrey,
      ),
      body: Row(
        children: [
          // Left column - Examples and features
          Expanded(flex: 1, child: _buildLeftColumn()),

          // Divider
          const VerticalDivider(thickness: 2, color: Colors.grey),

          // Right column - All available widgets
          Expanded(flex: 1, child: _buildRightColumn()),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Feature Examples'),
        const SizedBox(height: 20),

        // Basic rectangle
        _buildNodeExample(
          'Basic Rectangle',
          const RectangleNode(text: 'Process Step'),
        ),

        // With custom style
        _buildNodeExample(
          'Styled Rectangle',
          const RectangleNode(
            text: 'Custom Style',
            style: const NodeStyle(
              backgroundColor: Colors.lightBlue,
              borderColor: Colors.blue,
              textColor: Colors.white,
              borderType: BorderType.thick,
            ),
          ),
        ),

        // With link
        _buildNodeExample(
          'Rectangle with Link',
          RectangleNode(
            text: 'Click me!',
            style: const NodeStyle(textColor: Colors.blue, hasLink: true),
            onTap: () => debugPrint('Rectangle tapped!'),
          ),
        ),

        // With FontAwesome icons and emojis
        _buildNodeExample(
          'With FontAwesome Icons',
          RectangleNode(
            text: '🚀 Start fa:fa-arrow-right Process fa:fa-gear Settings',
            style: NodeStyle(
              backgroundColor: Colors.green,
              borderColor: Colors.green[900]!,
              textColor: Colors.white,
            ),
          ),
        ),

        // Multiple icons example
        _buildNodeExample(
          'Multiple Icons',
          const RectangleNode(
            text:
                'fa:fa-user User fa:fa-arrow-right fa:fa-database Data fa:fa-check Done',
            style: const NodeStyle(
              backgroundColor: Colors.indigo,
              borderColor: Colors.indigoAccent,
              textColor: Colors.white,
            ),
          ),
        ),

        // Business process example
        _buildNodeExample(
          'Business Process',
          const RectangleNode(
            text: 'fa:fa-briefcase Load\nfa:fa-chart-column Analytics',
            style: const NodeStyle(
              backgroundColor: Colors.orange,
              borderColor: Colors.deepOrange,
              textColor: Colors.white,
              borderType: BorderType.thick,
            ),
          ),
        ),

        // Dashed border
        _buildNodeExample(
          'Dashed Border',
          const RectangleNode(
            text: 'Dashed Rectangle',
            style: const NodeStyle(
              borderType: BorderType.dashed,
              borderColor: Colors.orange,
            ),
          ),
        ),

        const SizedBox(height: 20),
        _buildSection('Scale Factor Examples'),
        const SizedBox(height: 20),

        // Different scale factors
        ...List.generate(6, (index) {
          final scaleFactor = 1.0 + (index * 0.2);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildNodeExample(
              'Scale ${scaleFactor.toStringAsFixed(1)}x',
              CircleNode(
                text: 'Scale\n${scaleFactor.toStringAsFixed(1)}x',
                scaleFactor: scaleFactor,
                style: NodeStyle(
                  backgroundColor: HSVColor.fromAHSV(
                    1.0,
                    index * 60.0,
                    0.3,
                    1.0,
                  ).toColor(),
                  borderColor: HSVColor.fromAHSV(
                    1.0,
                    index * 60.0,
                    0.8,
                    0.8,
                  ).toColor(),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRightColumn() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('All Available Node Shapes'),
        const SizedBox(height: 20),

        // All node widgets
        _buildAllNodeWidgets(),
      ],
    );
  }

  Widget _buildAllNodeWidgets() {
    final nodeWidgets = [
      // Basic Shapes
      ('Rectangle', const RectangleNode(text: 'Process')),
      ('Circle', const CircleNode(text: 'Start')),
      ('Diamond', const DiamondNode(text: 'Decision?')),
      ('Stadium', const StadiumNode(text: 'Terminal')),
      ('Hexagon', const HexagonNode(text: 'Prepare')),
      ('Triangle', const TriangleNode(text: 'Extract')),

      // Geometric Variants
      ('Rounded Rectangle', const RoundedRectangleNode(text: 'Event')),
      ('Trapezoid', const TrapezoidNode(text: 'Manual\nOperation')),
      ('Small Circle', const SmallCircleNode(text: 'Start')),
      ('Double Circle', const DoubleCircleNode(text: 'Stop')),

      // Storage & Data
      ('Cylinder', const CylinderNode(text: 'Database')),
      ('Lined Cylinder', const LinedCylinderNode(text: 'Disk Storage')),
      (
        'Horizontal Cylinder',
        const HorizontalCylinderNode(text: 'Direct\nAccess'),
      ),
      ('Document', const DocumentNode(text: 'Document')),

      ('Lined Document', const LinedDocumentNode(text: 'Lined Document')),
      (
        'Multiple Documents\n',
        const MultipleDocumentNode(
          text:
              'Multi-Document'
              '',
        ),
      ),
      ('Odd', const OddNode(text: 'Odd Shape')),

      ('Bow Tie Rectangle', const BowTieRectangleNode(text: 'Stored\nData')),

      // Process Variants
      ('Framed Rectangle', const FramedRectangleNode(text: 'Subprocess')),
      (
        'Divided Rectangle',
        const DividedRectangleNode(text: 'Divided\nProcess'),
      ),
      (
      'Internal Storage',
      const InternalStorageNode(text: 'Internal\nStorage'),
      ),
      ('Lined Rectangle', const LinedRectangleNode(text: 'Lined\nProcess')),
      ('Stacked Rectangle', const StackedRectangleNode(text: 'Multi\nProcess')),

      // Input/Output
      ('Lean Right', const LeanRightNode(text: 'Input\nOutput')),
      ('Lean Left', const LeanLeftNode(text: 'Output\nInput')),
      ('Sloped Rectangle', const SlopedRectangleNode(text: 'Manual\nInput')),
      ('Curved Trapezoid', const CurvedTrapezoidNode(text: 'Display')),

      // Special Shapes
      ('Notched Rectangle', const NotchedRectangleNode(text: 'Card')),
      ('Hourglass', const HourglassNode()),
      ('Flipped Triangle', const FlippedTriangleNode(text: 'Manual\nFile')),
      ('Flag', const FlagNode(text: 'Paper\nTape')),
      ('Comment (left)', const CommentLeftNode(text: 'Comment left')),
      ('Comment (right)', const CommentRightNode(text: 'Comment right')),
      ('Braces', const BracesNode(text: 'Comment')),
      ('Bolt', const BoltNode()),

      // Circle Variants
      ('Filled Circle', const FilledCircleNode(text: 'Junction')),
      ('Crossed Circle', const CrossedCircleNode()),
    ];

    return Column(
      children: nodeWidgets.map((item) {
        final (name, widget) = item;
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              Center(child: widget),
              const SizedBox(height: 8),
              const Divider(color: Colors.grey),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildNodeExample(String title, Widget node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Center(child: node),
        const SizedBox(height: 16),
      ],
    );
  }
}
