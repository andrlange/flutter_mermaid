import 'package:flutter_mermaid2/src/core/models/flowchart/flowchart_node.dart';
import 'package:flutter_test/flutter_test.dart';

final List<String> testStrings = [
  // rect
  'ID@{shape: rect}',
  'ID[ TestText ]',
  'ID@{shape: proc}',
  'ID@{shape: process}',
  'ID@{shape: rectangle}',

  // rounded
  'ID@{shape: rounded}',
  'ID( TestText )',
  'ID@{shape: event}',

  // stadium
  'ID@{shape: stadium}',
  'ID([ TestText ])',
  'ID@{shape: pill}',
  'ID@{shape: terminal}',

  // subproc
  'ID@{shape: subproc}',
  'ID[[ TestText ]]',
  'ID@{shape: framed-rectangle}',
  'ID@{shape: subprocess}',
  'ID@{shape: subroutine}',

  // cyl
  'ID@{shape: cyl}',
  'ID[( TestText )]',
  'ID@{shape: cylinder}',
  'ID@{shape: database}',
  'ID@{shape: db}',

  // circle
  'ID@{shape: circle}',
  'ID(( TestText ))',
  'ID@{shape: circ}',

  // odd
  'ID@{shape: odd}',
  'ID> TestText ]',

  // diam
  'ID@{shape: diam}',
  'ID{ TestText }',
  'ID@{shape: decision}',
  'ID@{shape: diamond}',
  'ID@{shape: question}',

  // hex
  'ID@{shape: hex}',
  'ID{{ TestText }}',
  'ID@{shape: hexagon}',
  'ID@{shape: prepare}',

  // leanR
  'ID@{shape: lean-r}',
  'ID[/ TestText /]',
  'ID@{shape: in-out}',
  'ID@{shape: lean-right}',

  // leanL
  'ID@{shape: lean-l}',
  r'ID[\ TestText \]',
  'ID@{shape: lean-left}',
  'ID@{shape: out-in}',

  // trapB
  'ID@{shape: trap-b}',
  r'ID[/ TestText \]',
  'ID@{shape: priority}',
  'ID@{shape: trapezoid}',
  'ID@{shape: trapezoid-bottom}',

  // trapT
  'ID@{shape: trap-t}',
  r'ID[\ TestText /]',
  'ID@{shape: inv-trapezoid}',
  'ID@{shape: manual}',
  'ID@{shape: trapezoid-top}',

  // dblCirc
  'ID@{shape: dbl-circ}',
  'ID((( TestText )))',
  'ID@{shape: double-circle}',

  // text
  'ID@{shape: text}',

  // notchRect
  'ID@{shape: notch-rect}',
  'ID@{shape: card}',
  'ID@{shape: notched-rectangle}',

  // linRect
  'ID@{shape: lin-rect}',
  'ID@{shape: lin-proc}',
  'ID@{shape: lined-process}',
  'ID@{shape: lined-rectangle}',
  'ID@{shape: shaded-process}',

  // smCirc
  'ID@{shape: sm-circ}',
  'ID@{shape: small-circle}',
  'ID@{shape: start}',

  // framedCircle
  'ID@{shape: fr-circ}',
  'ID@{shape: framed-circle}',
  'ID@{shape: stop}',

  // fork
  'ID@{shape: fork}',
  'ID@{shape: join}',

  // hourglass
  'ID@{shape: hourglass}',
  'ID@{shape: collate}',

  // brace
  'ID@{shape: brace}',
  'ID@{shape: brace-l}',
  'ID@{shape: comment}',

  // braceR
  'ID@{shape: brace-r}',

  // braces
  'ID@{shape: braces}',

  // bolt
  'ID@{shape: bolt}',
  'ID@{shape: com-link}',
  'ID@{shape: lightning-bolt}',

  // doc
  'ID@{shape: doc}',
  'ID@{shape: document}',

  // delay
  'ID@{shape: delay}',
  'ID@{shape: half-rounded-rectangle}',

  // das
  'ID@{shape: das}',
  'ID@{shape: h-cyl}',
  'ID@{shape: horizontal-cylinder}',

  // linCyl
  'ID@{shape: lin-cyl}',
  'ID@{shape: disk}',
  'ID@{shape: lined-cylinder}',

  // curvTrap
  'ID@{shape: curv-trap}',
  'ID@{shape: curved-trapezoid}',
  'ID@{shape: display}',

  // divRect
  'ID@{shape: div-rect}',
  'ID@{shape: div-proc}',
  'ID@{shape: divided-process}',
  'ID@{shape: divided-rectangle}',

  // tri
  'ID@{shape: tri}',
  'ID@{shape: extract}',
  'ID@{shape: triangle}',

  // winPane
  'ID@{shape: win-pane}',
  'ID@{shape: internal-storage}',
  'ID@{shape: window-pane}',

  // fCirc
  'ID@{shape: f-circ}',
  'ID@{shape: filled-circle}',
  'ID@{shape: junction}',

  // linDoc
  'ID@{shape: lin-doc}',
  'ID@{shape: lined-document}',

  // notchPent
  'ID@{shape: notch-pent}',
  'ID@{shape: loop-limit}',
  'ID@{shape: notched-pentagon}',

  // flipTri
  'ID@{shape: flip-tri}',
  'ID@{shape: flipped-triangle}',
  'ID@{shape: manual-file]}',

  // slRect
  'ID@{shape: sl-rect}',
  'ID@{shape: manual-input}',
  'ID@{shape: sloped-rectangle}',

  // docs
  'ID@{shape: docs}',
  'ID@{shape: documents}',
  'ID@{shape: st-doc}',
  'ID@{shape: stacked-document}',

  // processes (st-rect)
  'ID@{shape: st-rect}',
  'ID@{shape: processes}',
  'ID@{shape: procs}',
  'ID@{shape: stacked-rectangle}',

  // flag
  'ID@{shape: flag}',
  'ID@{shape: paper-tape}',

  // bowRect
  'ID@{shape: bow-rect}',
  'ID@{shape: bow-tie-rectangle}',
  'ID@{shape: stored-data}',

  // crossCirc
  'ID@{shape: cross-circ}',
  'ID@{shape: crossed-circle}',
  'ID@{shape: summary}',

  // tagDoc
  'ID@{shape: tag-doc}',
  'ID@{shape: tagged-document}',

  // tagRect
  'ID@{shape: tag-rect}',
  'ID@{shape: tag-proc}',
  'ID@{shape: tagged-process}',
  'ID@{shape: tagged-rectangle}',
];

final List<FlowchartNodeShape> expectedShapes = [
  // rect
  FlowchartNodeShape.rect,
  FlowchartNodeShape.rect,
  FlowchartNodeShape.rect,
  FlowchartNodeShape.rect,
  FlowchartNodeShape.rect,

  // rounded
  FlowchartNodeShape.rounded,
  FlowchartNodeShape.rounded,
  FlowchartNodeShape.rounded,

  // stadium
  FlowchartNodeShape.stadium,
  FlowchartNodeShape.stadium,
  FlowchartNodeShape.stadium,
  FlowchartNodeShape.stadium,

  // subproc
  FlowchartNodeShape.subproc,
  FlowchartNodeShape.subproc,
  FlowchartNodeShape.subproc,
  FlowchartNodeShape.subproc,
  FlowchartNodeShape.subproc,

  // cyl
  FlowchartNodeShape.cyl,
  FlowchartNodeShape.cyl,
  FlowchartNodeShape.cyl,
  FlowchartNodeShape.cyl,
  FlowchartNodeShape.cyl,

  // circle
  FlowchartNodeShape.circle,
  FlowchartNodeShape.circle,
  FlowchartNodeShape.circle,

  // odd
  FlowchartNodeShape.odd,
  FlowchartNodeShape.odd,

  // diam
  FlowchartNodeShape.diam,
  FlowchartNodeShape.diam,
  FlowchartNodeShape.diam,
  FlowchartNodeShape.diam,
  FlowchartNodeShape.diam,

  // hex
  FlowchartNodeShape.hex,
  FlowchartNodeShape.hex,
  FlowchartNodeShape.hex,
  FlowchartNodeShape.hex,

  // leanR
  FlowchartNodeShape.leanR,
  FlowchartNodeShape.leanR,
  FlowchartNodeShape.leanR,
  FlowchartNodeShape.leanR,

  // leanL
  FlowchartNodeShape.leanL,
  FlowchartNodeShape.leanL,
  FlowchartNodeShape.leanL,
  FlowchartNodeShape.leanL,

  // trapB
  FlowchartNodeShape.trapB,
  FlowchartNodeShape.trapB,
  FlowchartNodeShape.trapB,
  FlowchartNodeShape.trapB,
  FlowchartNodeShape.trapB,

  // trapT
  FlowchartNodeShape.trapT,
  FlowchartNodeShape.trapT,
  FlowchartNodeShape.trapT,
  FlowchartNodeShape.trapT,
  FlowchartNodeShape.trapT,

  // dblCirc
  FlowchartNodeShape.dblCirc,
  FlowchartNodeShape.dblCirc,
  FlowchartNodeShape.dblCirc,

  // text
  FlowchartNodeShape.text,

  // notchRect
  FlowchartNodeShape.notchRect,
  FlowchartNodeShape.notchRect,
  FlowchartNodeShape.notchRect,

  // linRect
  FlowchartNodeShape.linRect,
  FlowchartNodeShape.linRect,
  FlowchartNodeShape.linRect,
  FlowchartNodeShape.linRect,
  FlowchartNodeShape.linRect,

  // smCirc
  FlowchartNodeShape.smCirc,
  FlowchartNodeShape.smCirc,
  FlowchartNodeShape.smCirc,

  // framedCircle
  FlowchartNodeShape.framedCircle,
  FlowchartNodeShape.framedCircle,
  FlowchartNodeShape.framedCircle,

  // fork
  FlowchartNodeShape.fork,
  FlowchartNodeShape.fork,

  // hourglass
  FlowchartNodeShape.hourglass,
  FlowchartNodeShape.hourglass,

  // brace
  FlowchartNodeShape.brace,
  FlowchartNodeShape.brace,
  FlowchartNodeShape.brace,

  // braceR
  FlowchartNodeShape.braceR,

  // braces
  FlowchartNodeShape.braces,

  // bolt
  FlowchartNodeShape.bolt,
  FlowchartNodeShape.bolt,
  FlowchartNodeShape.bolt,

  // doc
  FlowchartNodeShape.doc,
  FlowchartNodeShape.doc,

  // delay
  FlowchartNodeShape.delay,
  FlowchartNodeShape.delay,

  // das
  FlowchartNodeShape.das,
  FlowchartNodeShape.das,
  FlowchartNodeShape.das,

  // linCyl
  FlowchartNodeShape.linCyl,
  FlowchartNodeShape.linCyl,
  FlowchartNodeShape.linCyl,

  // curvTrap
  FlowchartNodeShape.curvTrap,
  FlowchartNodeShape.curvTrap,
  FlowchartNodeShape.curvTrap,

  // divRect
  FlowchartNodeShape.divRect,
  FlowchartNodeShape.divRect,
  FlowchartNodeShape.divRect,
  FlowchartNodeShape.divRect,

  // tri
  FlowchartNodeShape.tri,
  FlowchartNodeShape.tri,
  FlowchartNodeShape.tri,

  // winPane
  FlowchartNodeShape.winPane,
  FlowchartNodeShape.winPane,
  FlowchartNodeShape.winPane,

  // fCirc
  FlowchartNodeShape.fCirc,
  FlowchartNodeShape.fCirc,
  FlowchartNodeShape.fCirc,

  // linDoc
  FlowchartNodeShape.linDoc,
  FlowchartNodeShape.linDoc,

  // notchPent
  FlowchartNodeShape.notchPent,
  FlowchartNodeShape.notchPent,
  FlowchartNodeShape.notchPent,

  // flipTri
  FlowchartNodeShape.flipTri,
  FlowchartNodeShape.flipTri,
  FlowchartNodeShape.flipTri,

  // slRect
  FlowchartNodeShape.slRect,
  FlowchartNodeShape.slRect,
  FlowchartNodeShape.slRect,

  // docs
  FlowchartNodeShape.docs,
  FlowchartNodeShape.docs,
  FlowchartNodeShape.docs,
  FlowchartNodeShape.docs,

  // processes (st-rect)
  FlowchartNodeShape.processes,
  FlowchartNodeShape.processes,
  FlowchartNodeShape.processes,
  FlowchartNodeShape.processes,

  // flag
  FlowchartNodeShape.flag,
  FlowchartNodeShape.flag,

  // bowRect
  FlowchartNodeShape.bowRect,
  FlowchartNodeShape.bowRect,
  FlowchartNodeShape.bowRect,

  // crossCirc
  FlowchartNodeShape.crossCirc,
  FlowchartNodeShape.crossCirc,
  FlowchartNodeShape.crossCirc,

  // tagDoc
  FlowchartNodeShape.tagDoc,
  FlowchartNodeShape.tagDoc,

  // tagRect
  FlowchartNodeShape.tagRect,
  FlowchartNodeShape.tagRect,
  FlowchartNodeShape.tagRect,
  FlowchartNodeShape.tagRect,
];

void main() {
  group('Flowchart Model Tests', () {
    test('Check all possible options of node types with shortName, signature,'
        'alias', () {
      for (var i = 0; i < testStrings.length; i++) {
        final nodeStr = testStrings[i];
        final expected = expectedShapes[i];

        final matched = FlowchartNodeShape.values.firstWhere(
          (shape) => shape.isShape(nodeStr),
          orElse: () => throw Exception("No match for '$nodeStr'"),
        );

        print(
          'Testing $nodeStr (expected: ${expected.semanticName}, got: '
          '${matched.semanticName})',
        );
        assert(
          matched == expected,
          "Mismatch for '$nodeStr': got ${matched.semanticName}, "
          'expected ${expected.semanticName}',
        );
      }
    });
  });
}
