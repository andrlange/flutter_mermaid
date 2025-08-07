import 'package:flutter_mermaid2/src/core/models/flowchart/flowchart_node.dart';
import 'package:flutter_mermaid2/src/core/parser/mermaid_parser.dart';
import 'package:flutter_test/flutter_test.dart';


const String mermaidSyntax1 = '''
---
title: Frontmatter Example
displayMode: compact
config:
  theme: forest
gantt:
    useWidth: 400
    compact: true
---
gantt LR
    section Waffle
        Iron  : 1982, 3y
        House : 1986, 3y
''';

const String mermaidSyntax2 = '''
---
title: Flowchart Example
displayMode: normal
config:
  look: handDrawn
  theme: neutral
---
flowchart TB
    subgraph subgraph1
        direction TB
        top1[top] --> bottom1[bottom]
    end
    subgraph subgraph2
        direction TB
        top2[top] --> bottom2[bottom]
    end
    %% ^ These subgraphs are identical, except for the links to them:

    %% Link *to* subgraph1: subgraph1 direction is maintained
    outside --> subgraph1
    %% Link *within* subgraph2:
    %% subgraph2 inherits the direction of the top-level graph (LR)
    outside ---> subgraph2
''';



void main() {
  group('Test start for Parser Tests', () {

    test('Parse Mermaid 1 Syntax to extract type and config data', () {
      final mermaidObject = MermaidParser.parse
        (mermaidSyntax1);

      expect(mermaidObject.config.title, 'Frontmatter Example');
      expect(mermaidObject.config.theme, 'forest');
      expect(mermaidObject.config.displayMode, 'compact');
      expect(mermaidObject.mermaidType, MermaidType.gantt);
      expect(mermaidObject.mermaidDirection, MermaidDirection.lr);

      print('$mermaidObject\n');

    });

    test('Parse Mermaid 2 Syntax to extract type and config data', () {
      final mermaidObject = MermaidParser.parse
        (mermaidSyntax2);

      expect(mermaidObject.config.title, 'Flowchart Example');
      expect(mermaidObject.config.theme, 'neutral');
      expect(mermaidObject.config.displayMode, 'normal');
      expect(mermaidObject.mermaidType, MermaidType.flowchart);
      expect(mermaidObject.mermaidDirection, MermaidDirection.tb);

      print('$mermaidObject\n');

    });

    test('Flowchart node shapes', () {



      for(var shape in FlowchartNodeShape.values) {
        print(shape);
      }

    });
  });
}
