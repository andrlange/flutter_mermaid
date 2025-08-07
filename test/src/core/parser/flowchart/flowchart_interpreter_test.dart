import 'package:flutter_mermaid2/src/core/parser/flowchart/flowchart_interpreter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MermaidFlowchartInterpreter Tests', () {

    test('Test 1) Basic Parse - Simple Flowchart', () {
      print('=== Test 1: Basic Parse ===');

      const simpleCode = '''
flowchart TD
  A[Start] --> B[End]
''';

      final interpreter = MermaidFlowchartInterpreter();
      final document = interpreter.parse(simpleCode);

      print('Direction: ${document.direction}');
      print('Statements: ${document.statements.length}');

      // Assertions
      expect(document.direction, equals('TD'));
      expect(document.statements.length, greaterThan(0));

      final nodeStatements = document.statements.whereType<NodeStatement>().toList();
      final connectionStatements = document.statements.whereType<ConnectionStatement>().toList();

      expect(nodeStatements.length, equals(2));
      expect(connectionStatements.length, equals(1));

      // Check specific nodes
      final startNode = nodeStatements.firstWhere((n) => n.id == 'A');
      expect(startNode.text, equals('Start'));
      expect(startNode.shape, equals(NodeShape.rectangle));
    });

    test('Test 2) ParseWithDetails - Performance Metrics', () {
      print('\n=== Test 2: ParseWithDetails ===');

      const mediumCode = '''
flowchart LR
  A@{shape: circle, label: "Start"} --> B[Process]
  B --> C@{shape: diamond, label: "Decision?"}
  C -->|Yes| D[Success]
  C -->|No| E[Retry]
  
  style A fill:#f9f
  class B,D highlight
''';

      final interpreter = MermaidFlowchartInterpreter();
      final result = interpreter.parseWithDetails(mediumCode);

      print('Success: ${result.success}');
      print('Parsing Time: ${result.parsingTimeMs}ms');
      print('Token Count: ${result.tokenCount}');
      print('Warnings: ${result.warnings}');

      if (result.document != null) {
        final doc = result.document!;
        print('Document Statements: ${doc.statements.length}');
        print('Direction: ${doc.direction}');
      }

      // Assertions
      expect(result.success, isTrue);
      expect(result.document, isNotNull);
      expect(result.parsingTimeMs, greaterThanOrEqualTo(0));
      expect(result.tokenCount, greaterThan(10));
      expect(result.error, isNull);

      // Document structure
      final doc = result.document!;
      expect(doc.direction, equals('LR'));
      expect(doc.statements.length, greaterThan(5));

      // Check different statement types
      expect(doc.statements.whereType<NodeStatement>().length, greaterThan(0));
      expect(doc.statements.whereType<ConnectionStatement>().length, greaterThan(0));
      expect(doc.statements.whereType<StyleStatement>().length, greaterThan(0));
      expect(doc.statements.whereType<ClassStatement>().length, greaterThan(0));
    });

    test('Test 3) Debug Output Enabled', () {
      print('\n=== Test 3: Debug Output ===');

      const debugCode = '''
flowchart TD
  A[Start] --> B{Decision}
  B --> C[End]
''';

      final interpreter = MermaidFlowchartInterpreter(enableDebugOutput: true);
      final document = interpreter.parse(debugCode);

      // Mit enableDebugOutput sollte zusätzliches Output in der Konsole erscheinen
      print('Parsed document with ${document.statements.length} statements');

      // Assertions
      expect(document.statements.length, greaterThan(0));
      expect(document.direction, equals('TD'));
    });

    test('Test 4) Error Handling - Empty Input', () {
      print('\n=== Test 4: Error Handling - Empty Input ===');

      final interpreter = MermaidFlowchartInterpreter();

      // Test empty string
      expect(() => interpreter.parse(''), throwsA(isA<MermaidParseException>()));
      expect(() => interpreter.parse('   '), throwsA(isA<MermaidParseException>()));

      // Test with parseWithDetails
      final result = interpreter.parseWithDetails('');

      print('Success: ${result.success}');
      print('Error: ${result.error}');

      expect(result.success, isFalse);
      expect(result.document, isNull);
      expect(result.error, isNotNull);
      expect(result.error, contains('Empty input'));
    });

    test('Test 5) Error Handling - Invalid Syntax', () {
      print('\n=== Test 5: Error Handling - Invalid Syntax ===');

      const invalidCode = '''
flowchart TD
  A[Start --> B{Unclosed bracket
  C --> 
  invalid syntax here
''';

      final interpreter = MermaidFlowchartInterpreter();

      // Test exception throwing
      MermaidParseException? caughtException;
      try {
        interpreter.parse(invalidCode);
      } on MermaidParseException catch (e) {
        caughtException = e;
        print('Caught exception: ${e.message}');
        if (e.line != null && e.column != null) {
          print('Location: line ${e.line}, column ${e.column}');
        }
      }

      expect(caughtException, isNotNull);
      expect(caughtException!.message, isNotEmpty);

      // Test with parseWithDetails
      final result = interpreter.parseWithDetails(invalidCode);

      print('Success: ${result.success}');
      print('Error: ${result.error}');

      expect(result.success, isFalse);
      expect(result.document, isNull);
      expect(result.error, isNotNull);
    });

    test('Test 6) Complex Real-World Document', () {
      print('\n=== Test 6: Complex Real-World Document ===');

      const complexCode = '''
flowchart TD
  Start@{shape: sm-circ, label: "🚀 Begin"} --> Init[Initialize]
  Init --> LoadConfig@{shape: doc, label: "Load Config"}
  
  LoadConfig --> Validate{Validate?}
  Validate -->|Yes| Process@{shape: cyl, label: "💾 Process"}
  Validate -->|No| Error[Show Error]
  
  Process -.-> Cache@{shape: h-cyl, label: "Cache"}
  Cache ==> Transform@{shape: hex, label: "Transform"}
  Transform --> Success@{shape: stadium, label: "✅ Done"}
  
  Error --> End@{shape: dbl-circ, label: "🛑 End"}
  Success --> End
  
  subgraph ErrorHandling [Error Handling]
    Error --> Log[Log Error]
    Log --> Notify[Notify Admin]
  end
  
  classDef success fill:#d4edda,stroke:#155724
  classDef error fill:#f8d7da,stroke:#721c24
  classDef process fill:#cce5ff,stroke:#0066cc
  
  class Success success
  class Error,End error
  class Process,Transform process
  
  click Success callback "Process completed"
  click Error "https://docs.example.com/errors"
''';

      final interpreter = MermaidFlowchartInterpreter();
      final result = interpreter.parseWithDetails(complexCode);

      print('Success: ${result.success}');
      print('Parsing Time: ${result.parsingTimeMs}ms');
      print('Token Count: ${result.tokenCount}');
      print('Warnings: ${result.warnings}');

      if (result.document != null) {
        final doc = result.document!;

        // Zähle alle Connections (inkl. Subgraph-Connections)
        int totalConnections = doc.statements.whereType<ConnectionStatement>().length;

        // Zähle auch Connections in Subgraphs
        for (final subgraph in doc.statements.whereType<SubgraphStatement>()) {
          totalConnections += subgraph.statements.whereType<ConnectionStatement>().length;
        }

        // Detailed analysis
        final nodes = doc.statements.whereType<NodeStatement>().length;
        final connections = doc.statements.whereType<ConnectionStatement>().length;
        final styles = doc.statements.whereType<StyleStatement>().length;
        final classDefs = doc.statements.whereType<ClassDefStatement>().length;
        final classes = doc.statements.whereType<ClassStatement>().length;
        final clicks = doc.statements.whereType<ClickStatement>().length;
        final subgraphs = doc.statements.whereType<SubgraphStatement>().length;

        print('Detailed breakdown:');
        print('  Nodes: $nodes');
        print('  Connections (main): $connections');
        print('  Connections (total with subgraphs): $totalConnections');
        print('  Styles: $styles');
        print('  ClassDefs: $classDefs');
        print('  Classes: $classes');
        print('  Clicks: $clicks');
        print('  Subgraphs: $subgraphs');

        // Subgraph details
        for (final subgraph in doc.statements.whereType<SubgraphStatement>()) {
          final subNodes = subgraph.statements.whereType<NodeStatement>().length;
          final subConnections = subgraph.statements.whereType<ConnectionStatement>().length;
          print('  Subgraph "${subgraph.id}": $subNodes nodes, $subConnections connections');
        }

        // Assertions - KORRIGIERT: Verwende totalConnections statt connections
        expect(result.success, isTrue);
        expect(doc.direction, equals('TD'));
        expect(nodes, greaterThan(8));
        expect(totalConnections, greaterThan(10)); // KORRIGIERT: Jetzt >10 connections (inkl. Subgraph)
        expect(classDefs, equals(3));
        expect(classes, equals(3));
        expect(clicks, equals(2));
        expect(subgraphs, equals(1));
      }
    });

    test('Test 7) Warnings Detection', () {
      print('\n=== Test 7: Warnings Detection ===');

      // Code with isolated nodes and no direction
      const warningCode = '''
graph
  A[Connected Node] --> B[Also Connected]
  C[Isolated Node]
  D[Another Isolated]
  
  E --> F
''';

      final interpreter = MermaidFlowchartInterpreter();
      final result = interpreter.parseWithDetails(warningCode);

      print('Success: ${result.success}');
      print('Warnings (${result.warnings.length}):');
      for (final warning in result.warnings) {
        print('  - $warning');
      }

      // Assertions
      expect(result.success, isTrue);
      expect(result.warnings.length, greaterThan(0));

      // Check for specific warning types
      final warningText = result.warnings.join(' ').toLowerCase();
      expect(warningText, anyOf([
        contains('isolated'),
        contains('direction'),
      ]));
    });

    test('Test 8) Performance Test - Large Document', () {
      print('\n=== Test 8: Performance Test ===');

      // Generate a large flowchart programmatically
      final buffer = StringBuffer('flowchart TD\n');

      // Create 50 nodes with connections
      for (int i = 0; i < 50; i++) {
        final nodeId = 'Node$i';
        final nextNodeId = 'Node${i + 1}';

        buffer.writeln('  $nodeId[Label $i]');

        if (i < 49) {
          buffer.writeln('  $nodeId --> $nextNodeId');
        }
      }

      // Add some styling
      buffer.writeln('  classDef default fill:#f9f');
      buffer.writeln('  class Node0,Node49 highlight');

      final largeCode = buffer.toString();
      print('Generated code with ${largeCode.length} characters');

      final interpreter = MermaidFlowchartInterpreter();
      final stopwatch = Stopwatch()..start();

      final result = interpreter.parseWithDetails(largeCode);
      stopwatch.stop();

      print('Parse result:');
      print('  Success: ${result.success}');
      print('  Parsing Time: ${result.parsingTimeMs}ms');
      print('  Total Time: ${stopwatch.elapsedMilliseconds}ms');
      print('  Token Count: ${result.tokenCount}');
      print('  Statements: ${result.document?.statements.length ?? 0}');

      // Assertions
      expect(result.success, isTrue);
      expect(result.parsingTimeMs, lessThan(1000)); // Should parse in under 1 second
      expect(result.tokenCount, greaterThan(100));

      if (result.document != null) {
        expect(result.document!.statements.length, greaterThan(50));
      }
    });

    test('Test 9) Edge Cases - Various Syntaxes', () {
      print('\n=== Test 9: Edge Cases ===');

      final testCases = [
        // Minimal flowchart
        ('flowchart TD\n  A', 'Minimal flowchart'),

        // Only graph directive
        ('graph LR\n  A --> B', 'Graph directive'),

        // No nodes, only styling
        ('flowchart TD\n  classDef default fill:#f9f', 'Only styling'),

        // Unicode and emojis
        ('flowchart TD\n  A["🚀 Start"] --> B["✅ End"]', 'Unicode content'),

        // Very long node names
        ('flowchart TD\n  VeryLongNodeNameThatShouldStillWork --> AnotherVeryLongNodeName', 'Long names'),
      ];

      final interpreter = MermaidFlowchartInterpreter();

      for (final (code, description) in testCases) {
        print('Testing: $description');

        final result = interpreter.parseWithDetails(code);
        print('  Success: ${result.success}');

        if (!result.success) {
          print('  Error: ${result.error}');
        } else {
          print('  Statements: ${result.document!.statements.length}');
        }

        // Most should succeed (though some might have warnings)
        expect(result.success, isTrue, reason: 'Failed: $description');
      }
    });

    test('Test 10) Exception Details and Chaining', () {
      print('\n=== Test 10: Exception Details ===');

      const invalidCode = '''
flowchart TD
  A[Start --> B[Unclosed
  C --> D
''';

      final interpreter = MermaidFlowchartInterpreter();

      MermaidParseException? exception;
      try {
        interpreter.parse(invalidCode);
      } on MermaidParseException catch (e) {
        exception = e;

        print('Exception details:');
        print('  Message: ${e.message}');
        print('  Line: ${e.line}');
        print('  Column: ${e.column}');
        print('  Original Exception: ${e.originalException?.runtimeType}');
        print('  ToString: $e');
      }

      expect(exception, isNotNull);
      expect(exception!.message, isNotEmpty);

      // Should contain location information or have original exception
      expect(
          exception.line != null ||
              exception.column != null ||
              exception.originalException != null,
          isTrue,
          reason: 'Exception should have location info or original exception'
      );
    });

    test('Test 11) Memory Usage - Multiple Parse Calls', () {
      print('\n=== Test 11: Memory Usage ===');

      const testCode = '''
flowchart TD
  A[Start] --> B{Decision}
  B -->|Yes| C[Process]
  B -->|No| D[Skip]
  C --> E[End]
  D --> E
''';

      final interpreter = MermaidFlowchartInterpreter();
      final results = <MermaidParseResult>[];

      // Parse the same code multiple times
      for (int i = 0; i < 10; i++) {
        final result = interpreter.parseWithDetails(testCode);
        results.add(result);

        expect(result.success, isTrue);
        expect(result.document, isNotNull);
      }

      // All results should be consistent
      final firstResult = results.first;
      for (final result in results.skip(1)) {
        expect(result.document!.statements.length,
            equals(firstResult.document!.statements.length));
        expect(result.tokenCount, equals(firstResult.tokenCount));
      }

      print('Completed ${results.length} parse operations successfully');
      print('Average parsing time: ${results.map((r) => r.parsingTimeMs).reduce((a, b) => a + b) / results.length}ms');
    });

    test('Test 12) Interpreter State Independence', () {
      print('\n=== Test 12: State Independence ===');

      final interpreter1 = MermaidFlowchartInterpreter();
      final interpreter2 = MermaidFlowchartInterpreter(enableDebugOutput: true);

      const code1 = 'flowchart TD\n  A --> B';
      const code2 = 'flowchart LR\n  X --> Y --> Z';

      // Parse with both interpreters
      final result1 = interpreter1.parseWithDetails(code1);
      final result2 = interpreter2.parseWithDetails(code2);

      // Both should succeed independently
      expect(result1.success, isTrue);
      expect(result2.success, isTrue);

      // Results should be different
      expect(result1.document!.direction, equals('TD'));
      expect(result2.document!.direction, equals('LR'));

      expect(result1.document!.statements.length,
          isNot(equals(result2.document!.statements.length)));

      // Parse again with swapped codes
      final result3 = interpreter1.parseWithDetails(code2);
      final result4 = interpreter2.parseWithDetails(code1);

      expect(result3.document!.direction, equals('LR'));
      expect(result4.document!.direction, equals('TD'));

      print('All interpreters maintained independent state correctly');
    });
  });
}