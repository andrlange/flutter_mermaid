import 'dart:core';

import 'flowchart_node_style.dart';

enum FlowchartNodeShape {
  rect('rect', '[:]', 'Process', 'Rectangle', 'Standard process shape', [
    'proc',
    'process',
    'rectangle',
  ]),
  rounded(
    'rounded',
    '(:)',
    'Event',
    'Rounded Rectangle',
    'Represents an event',
    ['event'],
  ),
  stadium('stadium', '([:])', 'Terminal Point', 'Stadium', 'Terminal point', [
    'pill',
    'terminal',
  ]),
  subproc('subproc', '[[:]]', 'Subprocess', 'Framed Rectangle', 'Subprocess', [
    'framed-rectangle',
    'subprocess',
    'subroutine',
  ]),
  cyl('cyl', '[(:)]', 'Database', 'Cylinder', 'Database storage', [
    'cylinder',
    'database',
    'db',
  ]),
  circle('circle', '((:))', 'Start', 'Circle', 'Starting point', ['circ']),
  odd('odd', '>:]', 'Odd', 'Odd', '	Odd shape', []),
  diam('diam', '{:}', 'Decision', 'Diamond', 'Decision-making step', [
    'decision',
    'diamond',
    'question',
  ]),
  hex(
    'hex',
    '{{:}}',
    'Prepare Conditional',
    'Hexagon',
    'Preparation or '
        'condition step',
    ['hexagon', 'prepare'],
  ),
  leanR(
    'lean-r',
    '[/:/]',
    'Data Input/Output',
    'Lean Right',
    'Represents input '
        'or output',
    ['in-out', 'lean-right'],
  ),
  leanL(
    'lean-l',
    r'[\:\]',
    'Data Input/Output',
    'Lean Left',
    'Represents output'
        ' or input',
    ['lean-left', 'out-in'],
  ),
  trapB(
    'trap-b',
    r'[/:\]',
    'Priority Action',
    'Trapezoid Base Bottom',
    'Priorit'
        'y action',
    ['priority', 'trapezoid', 'trapezoid-bottom'],
  ),
  trapT(
    'trap-t',
    r'[\:/]',
    'Manual Operation',
    'Trapezoid Base Top',
    'Represent'
        's a manual task',
    ['inv-trapezoid', 'manual', 'trapezoid-top'],
  ),
  dblCirc(
    'dbl-circ',
    '(((:)))',
    'Stop',
    'Double Circle',
    'Represents a stop '
        'point',
    ['double-circle'],
  ),
  text('text', null, 'Text Block', 'Text Block', 'Text Block', []),
  notchRect(
    'notch-rect',
    null,
    'Card',
    'Notched Rectangle',
    'Represents a '
        'card',
    ['card', 'notched-rectangle'],
  ),
  linRect(
    'lin-rect',
    null,
    'Lined/Shaded Process',
    'Lined Rectangle',
    '	Lined '
        'process shape',
    ['lin-proc', 'lined-process', 'lined-rectangle', 'shaded-process'],
  ),
  smCirc('sm-circ', null, 'Start', 'Small Circle', 'Small starting point', [
    'small-circle',
    'start',
  ]),
  framedCircle('fr-circ', null, 'Stop', 'Framed Circle', 'Stop point', [
    'framed-circle',
    'stop',
  ]),
  fork(
    'fork',
    null,
    'Fork/Join',
    'Filled Rectangle',
    'Fork or join in process '
        'flow',
    ['join'],
  ),
  hourglass(
    'hourglass',
    null,
    'Collate',
    'Hourglass',
    'Represents a collate '
        'operation',
    ['collate', 'hourglass'],
  ),
  brace('brace', null, 'Comment', 'Curly Brace', 'Adds a comment', [
    'brace-l',
    'comment',
  ]),
  braceR('brace-r', null, 'Comment Right', 'Curly Brace', 'Adds a comment', []),
  braces(
    'braces',
    null,
    'Comment with braces on both sides',
    'Curly Brace',
    'Adds a comment',
    [],
  ),
  bolt('bolt', null, 'Com Link', 'Lightning Bolt', 'Communication link', [
    'com-link',
    'lightning-bolt',
  ]),
  doc('doc', null, 'Document', 'Document', '	Represents a document', [
    'document',
  ]),
  delay(
    'delay',
    null,
    'Delay',
    'Half-Rounded Rectangle',
    'Represents a delay',
    ['half-rounded-rectangle'],
  ),
  das(
    'das',
    null,
    'Direct Access Storage',
    'Horizontal Cylinder',
    'Direct '
        'access storage',
    ['h-cyl', 'horizontal-cylinder'],
  ),
  linCyl('lin-cyl', null, 'Disk Storage', 'Lined Cylinder', 'Disk storage', [
    'disk',
    'lined-cylinder',
  ]),
  curvTrap(
    'curv-trap',
    null,
    'Display',
    'Curved Trapezoid',
    'Represents a '
        'display',
    ['curved-trapezoid', 'display'],
  ),
  divRect(
    'div-rect',
    null,
    'Divided Process',
    'Divided Rectangle',
    'Divided '
        'process shape',
    ['div-proc', 'divided-process', 'divided-rectangle'],
  ),
  tri('tri', null, 'Extract', 'Triangle', 'Extraction process', [
    'extract',
    'triangle',
  ]),
  winPane(
    'win-pane',
    null,
    'Internal Storage',
    'Window Pane',
    'nternal '
        'storage',
    ['internal-storage', 'window-pane'],
  ),
  fCirc('f-circ', null, 'Junction', 'Filled Circle', 'Junction point', [
    'filled-circle',
    'junction',
  ]),
  linDoc(
    'lin-doc',
    null,
    'Lined Document',
    'Lined Document',
    'Lined document',
    ['lined-document'],
  ),
  notchPent(
    'notch-pent',
    null,
    'Loop Limit',
    'Trapezoidal Pentagon',
    'Loop limit step',
    ['loop-limit', 'notched-pentagon'],
  ),
  flipTri(
    'flip-tri',
    null,
    'Manual File',
    'Flipped Triangle',
    'Manual file '
        'operation',
    ['flipped-triangle', 'manual-file]'],
  ),
  slRect(
    'sl-rect',
    null,
    'Manual Input',
    '	Sloped Rectangle',
    'Manual input '
        'step',
    ['manual-input', 'sloped-rectangle'],
  ),
  docs(
    'docs',
    null,
    'Multi-Document',
    'Stacked Document',
    'Multiple documents',
    ['documents', 'st-doc', 'stacked-document'],
  ),
  processes(
    'st-rect',
    null,
    'Multi-Process',
    'Stacked Rectangle',
    'Multiple '
        'processes',
    ['processes', 'procs', 'stacked-rectangle'],
  ),
  flag('flag', null, 'Paper Tape', 'Flag', 'Paper tape', ['paper-tape']),
  bowRect('bow-rect', null, 'Stored Data', 'Bow Tie Rectangle', 'Stored data', [
    'bow-tie-rectangle',
    'stored-data',
  ]),
  crossCirc('cross-circ', null, 'Summary', 'Crossed Circle', 'Summary', [
    'crossed-circle',
    'summary',
  ]),
  tagDoc(
    'tag-doc',
    null,
    'Tagged Document',
    'Tagged Document',
    'Tagged '
        'document',
    ['tagged-document'],
  ),
  tagRect(
    'tag-rect',
    null,
    'Tagged Process',
    'Tagged Rectangle',
    'Tagged '
        'process',
    ['tag-proc', 'tagged-process', 'tagged-rectangle'],
  );

  const FlowchartNodeShape(
    this.shortName,
    this._shapeSignature,
    this.semanticName,
    this.shapeName,
    this.description,
    this.alias,
  );

  final String shortName;
  final String? _shapeSignature;
  final String semanticName;
  final String shapeName;
  final String description;
  final List<String> alias;

  String get shapeSignature => _shapeSignature ?? '';

  bool isShape(String node) {
    /*
     * 1) Check if the node matches the shape signature if not @.
     * 2) Check if the node matches the short name.
     * 3) Check if the node is in the alias list.
     */

    var result = false;
    final comparator = node.toLowerCase().trim();
    // 1)
    if (_shapeSignature != null && !comparator.contains('@')) {
      final parts = _shapeSignature.split(':');

      if (parts.length == 2) {
        final startSignature = _extractStartSignature(comparator);
        final tmp = comparator.replaceFirst(startSignature, '');
        final endSignature = _extractEndSignature(tmp);

        result =
            parts[0].startsWith(startSignature) &&
            parts[1].startsWith(endSignature);

        if (result) {
          return result;
        }
      }
    }

    const identifier = 'shape:';
    if (comparator.contains(identifier) && comparator.contains('@')) {
      // 2)
      result = _containsName(comparator, shortName);
      if (result) {
        return result;
      }
      // 3)
      if (alias.isNotEmpty) {
        for (var ali in alias) {
          result = _containsName(comparator, ali);
          if (result) {
            break;
          }
        }
      }
    }

    return result;
  }

  @override
  String toString() {
    return 'FlowchartNodeShape:  \n  shortName: $shortName\n'
        '  shapeSignature: $shapeSignature\n'
        '  semanticName: $semanticName\n  shapeName: $shapeName\n'
        '  description: $description\n  alias:$alias';
  }

  String _extractStartSignature(String node) {
    final chars = ['(', '[', '{', '>', r'\', '/'];
    return _extractSignature(node, chars);
  }

  String _extractEndSignature(String node) {
    final chars = [')', ']', '}', r'\', '/'];
    return _extractSignature(node, chars);
  }

  String _extractSignature(String node, List<String> chars) {
    final stringBuffer = StringBuffer();

    var start = false;
    var end = false;
    for (var i = 0; i < node.length; i++) {
      if (chars.contains(node[i])) {
        if (!start) {
          start = true;
        }
        stringBuffer.write(node[i]);
      } else {
        if (start) {
          end = true;
        }
        if (end) {
          break;
        }
      }
    }
    return stringBuffer.toString();
  }

  bool _containsName(String node, String name) {
    var result = false;
    // check if name begins with :,' ' and ends with :,' ', or }

    if (node.contains(name) &&
        (node.contains(':$name') || node.contains(' $name')) &&
        (node.contains('$name ') ||
            node.contains('$name,') ||
            node.contains('$name}'))) {
      result = true;
    }

    return result;
  }
}

class FlowchartNode {
  FlowchartNode({String? id, required this.shape, required this.label,
  FlowchartNodeStyle? style}) {
    this.id = id ?? 'flowchart_${DateTime.now().millisecondsSinceEpoch}';
    this.style = style?? const FlowchartNodeStyle();
  }

  late final String id;
  final FlowchartNodeShape shape;
  final String label;
  late final FlowchartNodeStyle style;
}
