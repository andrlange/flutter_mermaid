import 'package:flutter_mermaid2/src/core/parser/flowchart/flowchart_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MermaidFlowchartParser Tests', () {

    test('Test 1) Basic Flowchart Document', () {
      print('=== Test 1: Basic Flowchart Document ===');

      const basicCode = '''
flowchart TD
  A[Start] --> B{Decision}
  B --> C[Process 1]
  B --> D[Process 2]
''';

      final lexer = MermaidLexer(basicCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      print('Direction: ${document.direction}');
      print('Statements: ${document.statements.length}');

      // Assertions
      expect(document.direction, equals('TD'));
      expect(document.statements.length, equals(7)); // Korrigiert: 4 nodes +
      // 3 connections = 7, aber Parser macht 6

      // Check node statements
      final nodeStatements = document.statements.whereType<NodeStatement>().toList();
      final connectionStatements = document.statements.whereType<ConnectionStatement>().toList();

      print('Node statements: ${nodeStatements.length}');
      print('Connection statements: ${connectionStatements.length}');

      for (final node in nodeStatements) {
        print('  Node: ${node.id} -> ${node.shape} (${node.text})');
      }

      for (final conn in connectionStatements) {
        print('  Connection: ${conn.fromId} ${conn.type} ${conn.toId}');
      }

      expect(nodeStatements.length, greaterThan(0));
      expect(connectionStatements.length, greaterThan(0));

      // Check specific nodes
      const expectedNodes = ['A', 'B', 'C', 'D'];
      for (final expectedId in expectedNodes) {
        final node = nodeStatements.where((n) => n.id == expectedId).firstOrNull;
        if (node != null) {
          print('  ✓ Found node: ${node.id} (${node.text})');
        } else {
          print('  ❌ Missing node: $expectedId');
        }
      }

      expect(nodeStatements.length, equals(4), reason: 'Should have 4 nodes: A, B, C, D');

      final nodeIds = nodeStatements.map((n) => n.id).toList();
      expect(nodeIds, containsAll(['A', 'B', 'C', 'D']), reason: 'Should contain all node IDs');

      // Check specific nodes
      final startNode = nodeStatements.firstWhere((n) => n.id == 'A');
      expect(startNode.shape, equals(NodeShape.rectangle));
      expect(startNode.text, equals('Start'));

      final decisionNode = nodeStatements.firstWhere((n) => n.id == 'B');
      expect(decisionNode.shape, equals(NodeShape.rhombus));
      expect(decisionNode.text, equals('Decision'));

      // Check C and D nodes
      final cNode = nodeStatements.where((n) => n.id == 'C').firstOrNull;
      if (cNode != null) {
        expect(cNode.shape, equals(NodeShape.rectangle));
        expect(cNode.text, equals('Process 1'));
      }

      final dNode = nodeStatements.where((n) => n.id == 'D').firstOrNull;
      if (dNode != null) {
        expect(dNode.shape, equals(NodeShape.rectangle));
        expect(dNode.text, equals('Process 2'));
      }
    });

    test('Test 2) New Shape Syntax @{shape...}', () {
      print('\n=== Test 2: New Shape Syntax ===');

      const newShapeCode = '''
flowchart LR
  A@{shape: circle, label: "Start"} --> B@{shape: rect, label: "Process"}
  B --> C@{shape: diamond, label: "Decision?"}
  C --> D@{shape: stadium, label: "End"}
''';

      final lexer = MermaidLexer(newShapeCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      print('Direction: ${document.direction}');
      print('Statements: ${document.statements.length}');

      final nodeStatements = document.statements.whereType<NodeStatement>().toList();

      for (final node in nodeStatements) {
        print('  Node: ${node.id} -> ${node.shape} (${node.text})');
        if (node.shapeParams != null) {
          print('    Params: ${node.shapeParams}');
        }
      }

      // Assertions
      expect(document.direction, equals('LR'));
      expect(nodeStatements.length, equals(4));

      // Check specific shape mappings
      final circleNode = nodeStatements.firstWhere((n) => n.id == 'A');
      expect(circleNode.shape, equals(NodeShape.circle));
      expect(circleNode.text, equals('Start'));

      final rectNode = nodeStatements.firstWhere((n) => n.id == 'B');
      expect(rectNode.shape, equals(NodeShape.rectangle));
      expect(rectNode.text, equals('Process'));

      final diamondNode = nodeStatements.firstWhere((n) => n.id == 'C');
      expect(diamondNode.shape, equals(NodeShape.rhombus)); // diamond mapped to rhombus
      expect(diamondNode.text, equals('Decision?'));

      final stadiumNode = nodeStatements.firstWhere((n) => n.id == 'D');
      expect(stadiumNode.shape, equals(NodeShape.stadium));
      expect(stadiumNode.text, equals('End'));
    });

    test('Test 3) All Connection Types', () {
      print('\n=== Test 3: All Connection Types ===');

      const connectionCode = '''
flowchart TD
  A --> B
  B --- C
  C -.-> D
  D ==> E
  E <--> F
  F o--o G
  G x--x H
  H <--o I
  I x--> J
''';

      final lexer = MermaidLexer(connectionCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final connectionStatements = document.statements.whereType<ConnectionStatement>().toList();

      print('Connection statements: ${connectionStatements.length}');
      for (final conn in connectionStatements) {
        print('  ${conn.fromId} ${conn.type} ${conn.toId}');
      }

      // Assertions
      expect(connectionStatements.length, greaterThan(8));

      // Check specific connection types
      final connectionTypes = connectionStatements.map((c) => c.type).toSet();
      expect(connectionTypes.contains(ConnectionType.arrow), isTrue);
      expect(connectionTypes.contains(ConnectionType.line), isTrue);
      expect(connectionTypes.contains(ConnectionType.dottedArrow), isTrue);
      expect(connectionTypes.contains(ConnectionType.thickArrow), isTrue);
      expect(connectionTypes.contains(ConnectionType.bidirectional), isTrue);
      expect(connectionTypes.contains(ConnectionType.bidirectionalCircle), isTrue);
      expect(connectionTypes.contains(ConnectionType.bidirectionalCross), isTrue);
      expect(connectionTypes.contains(ConnectionType.arrowToCircle), isTrue);
      expect(connectionTypes.contains(ConnectionType.crossToArrow), isTrue);
    });

    test('Test 4) FontAwesome Support', () {
      print('\n=== Test 4: FontAwesome Support ===');

      const fontAwesomeCode = '''
flowchart LR
  A[fa:fa-user Start] --> B@{shape: circle, label: "fa:fa-database Data"}
  B --> C["fa:fa-cog Process"]
''';

      final lexer = MermaidLexer(fontAwesomeCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final nodeStatements = document.statements.whereType<NodeStatement>().toList();

      for (final node in nodeStatements) {
        print('  Node: ${node.id} -> ${node.shape}');
        print('    Text: ${node.text}');
        print('    FontAwesome: ${node.fontAwesome}');
      }

      // Assertions
      expect(nodeStatements.length, equals(3));

      // Check FontAwesome parsing
      final nodesWithFontAwesome = nodeStatements.where((n) => n.fontAwesome != null).toList();
      expect(nodesWithFontAwesome.length, greaterThan(0));

      // Check specific FontAwesome instances
      for (final node in nodesWithFontAwesome) {
        expect(node.fontAwesome, isNotNull);
        expect(node.fontAwesome!.prefix, equals('fa'));
        expect(node.fontAwesome!.iconName, startsWith('fa-'));
      }
    });

    test('Test 5) Style Statements', () {
      print('\n=== Test 5: Style Statements ===');

      const styleCode = '''
flowchart TD
  A[Start] --> B[Process]
  
  style A fill:#f9f,stroke:#333,stroke-width:4px
  style B fill:#bbf,stroke:#333,stroke-width:2px
''';

      final lexer = MermaidLexer(styleCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final styleStatements = document.statements.whereType<StyleStatement>().toList();

      print('Style statements: ${styleStatements.length}');
      for (final style in styleStatements) {
        print('  Target: ${style.target}');
        print('  Properties: ${style.properties}');
      }

      // Assertions
      expect(styleStatements.length, equals(2));

      final styleA = styleStatements.firstWhere((s) => s.target == 'A');
      expect(styleA.properties.containsKey('fill'), isTrue);
      expect(styleA.properties.containsKey('stroke'), isTrue);
      expect(styleA.properties.containsKey('stroke-width'), isTrue);

      expect(styleA.properties['fill'], equals('#f9f'));
    });

    test('Test 6) ClassDef and Class Statements', () {
      print('\n=== Test 6: ClassDef and Class Statements ===');

      const classCode = '''
flowchart TD
  A[Start] --> B[Process] --> C[End]
  
  classDef default fill:#f9f,stroke:#333,stroke-width:2px
  classDef highlight fill:#ff0,stroke:#f00,stroke-width:4px
  
  class A,C highlight
  class B default
''';

      final lexer = MermaidLexer(classCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final classDefStatements = document.statements.whereType<ClassDefStatement>().toList();
      final classStatements = document.statements.whereType<ClassStatement>().toList();

      print('ClassDef statements: ${classDefStatements.length}');
      for (final classDef in classDefStatements) {
        print('  ClassName: ${classDef.className}');
        print('  Properties: ${classDef.properties}');
      }

      print('Class statements: ${classStatements.length}');
      for (final classStmt in classStatements) {
        print('  Nodes: ${classStmt.nodeIds}');
        print('  ClassName: ${classStmt.className}');
      }

      // Assertions
      expect(classDefStatements.length, equals(2));
      expect(classStatements.length, equals(2));

      // Check ClassDef
      final defaultClassDef = classDefStatements.firstWhere((c) => c.className == 'default');
      expect(defaultClassDef.properties.containsKey('fill'), isTrue);

      final highlightClassDef = classDefStatements.firstWhere((c) => c.className == 'highlight');
      expect(highlightClassDef.properties.containsKey('fill'), isTrue);
      expect(highlightClassDef.properties['fill'], equals('#ff0'));

      // Check Class assignments
      final highlightClass = classStatements.firstWhere((c) => c.className == 'highlight');
      expect(highlightClass.nodeIds, containsAll(['A', 'C']));
    });

    test('Test 7) Click Statements', () {
      print('\n=== Test 7: Click Statements ===');

      const clickCode = '''
flowchart LR
  A[Start] --> B[Process] --> C[End]
  
  click A callback "This is a callback"
  click B "https://example.com" "Open Link"
  click C call myFunction() "Call Function"
''';

      final lexer = MermaidLexer(clickCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final clickStatements = document.statements.whereType<ClickStatement>().toList();

      print('Click statements: ${clickStatements.length}');
      for (final click in clickStatements) {
        print('  Node: ${click.nodeId}');
        print('  Action: ${click.action.runtimeType}');
        print('  Tooltip: ${click.tooltip}');
      }

      // Assertions
      expect(clickStatements.length, equals(3));

      // Check different action types
      final callbackClick = clickStatements.firstWhere((c) => c.nodeId == 'A');
      expect(callbackClick.action, isA<CallbackAction>());
      expect(callbackClick.tooltip, equals('This is a callback'));

      final linkClick = clickStatements.firstWhere((c) => c.nodeId == 'B');
      expect(linkClick.action, isA<LinkAction>());
      expect((linkClick.action as LinkAction).url, equals('https://example.com'));
    });

    test('Test 8) LinkStyle Statements', () {
      print('\n=== Test 8: LinkStyle Statements ===');

      const linkStyleCode = '''
flowchart TD
  A --> B --> C --> D
  
  linkStyle 0 stroke:#f9f,stroke-width:4px
  linkStyle 1,2 stroke:#bbf,stroke-width:2px
''';

      final lexer = MermaidLexer(linkStyleCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final linkStyleStatements = document.statements.whereType<LinkStyleStatement>().toList();

      print('LinkStyle statements: ${linkStyleStatements.length}');
      for (final linkStyle in linkStyleStatements) {
        print('  Indices: ${linkStyle.linkIndices}');
        print('  Properties: ${linkStyle.properties}');
      }

      // Assertions
      expect(linkStyleStatements.length, equals(2));

      final firstLinkStyle = linkStyleStatements[0];
      expect(firstLinkStyle.linkIndices, equals([0]));
      expect(firstLinkStyle.properties.containsKey('stroke'), isTrue);
      expect(firstLinkStyle.properties['stroke'], equals('#f9f'));

      final secondLinkStyle = linkStyleStatements[1];
      expect(secondLinkStyle.linkIndices, equals([1, 2]));
      expect(secondLinkStyle.properties.containsKey('stroke'), isTrue);
    });

    test('Test 9) Subgraph Support', () {
      print('\n=== Test 9: Subgraph Support ===');

      const subgraphCode = '''
flowchart TD
  A[Start] --> B[Gateway]
  
  subgraph SG1 [Subgraph Title]
    B --> C[Process 1]
    B --> D[Process 2]
    C --> E[Merge]
    D --> E
  end
  
  E --> F[End]
''';

      final lexer = MermaidLexer(subgraphCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final subgraphStatements = document.statements.whereType<SubgraphStatement>().toList();

      print('Subgraph statements: ${subgraphStatements.length}');
      for (final subgraph in subgraphStatements) {
        print('  ID: ${subgraph.id}');
        print('  Title: ${subgraph.title}');
        print('  Statements: ${subgraph.statements.length}');

        for (final stmt in subgraph.statements) {
          if (stmt is NodeStatement) {
            print('    Node: ${stmt.id} (${stmt.text})');
          } else if (stmt is ConnectionStatement) {
            print('    Connection: ${stmt.fromId} -> ${stmt.toId}');
          }
        }
      }

      // Assertions
      expect(subgraphStatements.length, equals(1));

      final subgraph = subgraphStatements.first;
      expect(subgraph.id, equals('SG1'));
      expect(subgraph.title, equals('Subgraph Title'));
      expect(subgraph.statements.length, greaterThan(4));

      // Check that subgraph contains nodes
      final subgraphNodes = subgraph.statements.whereType<NodeStatement>().toList();
      final subgraphConnections = subgraph.statements.whereType<ConnectionStatement>().toList();

      expect(subgraphNodes.length, greaterThan(0));
      expect(subgraphConnections.length, greaterThan(0));
    });

    test('Test 10) Complex Real-World Example', () {
      print('\n=== Test 10: Complex Real-World Example ===');

      const complexCode = '''
flowchart TD
  Start@{shape: sm-circ, label: "🚀 Start Process"} --> Init[Initialize System]
  Init --> LoadConfig@{shape: doc, label: "Load Config"}
  
  LoadConfig --> ValidateInput{Validate Input?}
  ValidateInput -->|Yes| ProcessData@{shape: cyl, label: "💾 Database"}
  ValidateInput -->|No| ShowError[Display Error Message]
  
  ProcessData -.-> Cache@{shape: h-cyl, label: "Cache Layer"}
  Cache ==> Transform@{shape: hex, label: "Transform Data"}
  Transform --> Decision@{shape: diam, label: "Success?"}
  
  Decision -->|Success| Success@{shape: stadium, label: "✅ Complete"}
  Decision -->|Failed| Retry@{shape: trap-b, label: "Retry Logic"}
  
  Retry ~~~ ProcessData
  ShowError --> End@{shape: dbl-circ, label: "🛑 End"}
  Success --> End
  
  subgraph ErrorHandling [Error Handling]
    ShowError --> LogError[Log Error]
    LogError --> NotifyAdmin[Notify Admin]
  end
  
  %% Styling
  classDef success fill:#d4edda,stroke:#155724,stroke-width:2px
  classDef error fill:#f8d7da,stroke:#721c24,stroke-width:2px
  classDef process fill:#cce5ff,stroke:#0066cc,stroke-width:2px
  
  class Success success
  class ShowError,End error
  class ProcessData,Transform process
  
  click Success callback "Process completed successfully"
  click ShowError "https://docs.example.com/errors" "Error Documentation"
''';

      final lexer = MermaidLexer(complexCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      print('Total statements: ${document.statements.length}');

      // Categorize statements
      final nodeStatements = document.statements.whereType<NodeStatement>().toList();
      final connectionStatements = document.statements.whereType<ConnectionStatement>().toList();
      final styleStatements = document.statements.whereType<StyleStatement>().toList();
      final classDefStatements = document.statements.whereType<ClassDefStatement>().toList();
      final classStatements = document.statements.whereType<ClassStatement>().toList();
      final clickStatements = document.statements.whereType<ClickStatement>().toList();
      final subgraphStatements = document.statements.whereType<SubgraphStatement>().toList();

      print('Nodes: ${nodeStatements.length}');
      print('Connections: ${connectionStatements.length}');
      print('Styles: ${styleStatements.length}');
      print('ClassDefs: ${classDefStatements.length}');
      print('Classes: ${classStatements.length}');
      print('Clicks: ${clickStatements.length}');
      print('Subgraphs: ${subgraphStatements.length}');

      // Test various shapes
      final shapeTypes = nodeStatements.map((n) => n.shape).toSet();
      print('Shape types used: $shapeTypes');

      // Test connection types
      final connectionTypes = connectionStatements.map((c) => c.type).toSet();
      print('Connection types used: $connectionTypes');

      // Assertions
      expect(document.direction, equals('TD'));
      expect(nodeStatements.length, greaterThan(10));
      expect(connectionStatements.length, greaterThan(10));
      expect(classDefStatements.length, equals(3));
      expect(classStatements.length, equals(3));
      expect(clickStatements.length, equals(2));
      expect(subgraphStatements.length, equals(1));

      // Check specific shapes are parsed correctly
      expect(shapeTypes.contains(NodeShape.smCirc), isTrue);   // sm-circ
      expect(shapeTypes.contains(NodeShape.doc), isTrue);      // doc
      expect(shapeTypes.contains(NodeShape.cylinder), isTrue);      // cyl
      expect(shapeTypes.contains(NodeShape.hCyl), isTrue);     // h-cyl
      expect(shapeTypes.contains(NodeShape.hexagon), isTrue);      // hex
      expect(shapeTypes.contains(NodeShape.diam), isTrue);     // diam
      expect(shapeTypes.contains(NodeShape.stadium), isTrue);  // stadium
      expect(shapeTypes.contains(NodeShape.trapB), isTrue);    // trap-b
      expect(shapeTypes.contains(NodeShape.dblCirc), isTrue);  // dbl-circ

      // Check connection types
      expect(connectionTypes.contains(ConnectionType.arrow), isTrue);
      expect(connectionTypes.contains(ConnectionType.dottedArrow), isTrue);
      expect(connectionTypes.contains(ConnectionType.thickArrow), isTrue);
      expect(connectionTypes.contains(ConnectionType.invisibleLink), isTrue);

      // Check text parsing (including emojis)
      final startNode = nodeStatements.firstWhere((n) => n.id == 'Start');
      expect(startNode.text, contains('🚀'));

      final successNode = nodeStatements.firstWhere((n) => n.id == 'Success');
      expect(successNode.text, contains('✅'));
    });

    test('Test 11) Error Handling - Invalid Syntax', () {
      print('\n=== Test 11: Error Handling ===');

      const invalidCode = '''
flowchart TD
  A[Start] --> B{Decision
  C@{incomplete syntax
  D --> 
  --> E
  invalid statement here
  F[End]
''';

      final lexer = MermaidLexer(invalidCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);

      // Should not throw, but handle gracefully
      expect(() {
        final document = parser.parse();
        print('Successfully parsed document with ${document.statements.length} statements despite errors');

        // Should have parsed at least some valid statements
        final nodeStatements = document.statements.whereType<NodeStatement>().toList();
        final connectionStatements = document.statements.whereType<ConnectionStatement>().toList();

        print('Nodes parsed: ${nodeStatements.length}');
        print('Connections parsed: ${connectionStatements.length}');

        for (final node in nodeStatements) {
          print('  Node: ${node.id} (${node.text})');
        }
      }, returnsNormally);
    });

    test('Test 12) Mixed Classic and New Syntax', () {
      print('\n=== Test 12: Mixed Syntax ===');

      const mixedCode = '''
flowchart LR
  ClassicRect[Rectangle] --> NewCircle@{shape: circle, label: "Circle"}
  NewCircle --> ClassicRound(Round Node)
  ClassicRound --> NewHex@{shape: hex, label: "Hexagon"}
  
  ClassicDecision{Decision?} --> ClassicRect
  NewHex --> ClassicDecision
''';

      final lexer = MermaidLexer(mixedCode);
      final tokens = lexer.tokenize();
      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      final nodeStatements = document.statements.whereType<NodeStatement>().toList();

      print('Mixed syntax nodes:');
      for (final node in nodeStatements) {
        print('  ${node.id}: ${node.shape} - "${node.text}"');
        if (node.shapeParams != null) {
          print('    (New syntax with params)');
        }
      }

      // Assertions
      expect(nodeStatements.length, equals(5));

      // Check classic syntax nodes
      final rectNode = nodeStatements.firstWhere((n) => n.id == 'ClassicRect');
      expect(rectNode.shape, equals(NodeShape.rectangle));
      expect(rectNode.text, equals('Rectangle'));
      expect(rectNode.shapeParams, isNull); // Classic syntax has no params

      final roundNode = nodeStatements.firstWhere((n) => n.id == 'ClassicRound');
      expect(roundNode.shape, equals(NodeShape.rounded));

      final decisionNode = nodeStatements.firstWhere((n) => n.id == 'ClassicDecision');
      expect(decisionNode.shape, equals(NodeShape.rhombus));

      // Check new syntax nodes
      final circleNode = nodeStatements.firstWhere((n) => n.id == 'NewCircle');
      expect(circleNode.shape, equals(NodeShape.circle));
      expect(circleNode.text, equals('Circle'));
      // Note: shapeParams might be null in current implementation

      final hexNode = nodeStatements.firstWhere((n) => n.id == 'NewHex');
      expect(hexNode.shape, equals(NodeShape.hexagon));
      expect(hexNode.text, equals('Hexagon'));
    });
  });
}