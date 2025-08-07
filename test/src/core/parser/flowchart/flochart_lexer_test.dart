import 'package:flutter_mermaid2/src/core/parser/flowchart/flowchart_lexer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flowchart Lexer Tests', () {
    test('Test 1) Basic Flowchart', () {
      print('=== Test 1: Basic Flowchart ===');

      const basicCode = '''
flowchart TD
  A[Start] --> B{Decision}
  B --> C[Process 1]
  B --> D[Process 2]
  C --> E[End]
  D ------> E
  style A fill:#f9f,stroke:#333,stroke-width:4px
''';

      final lexer = MermaidLexer(basicCode);
      final tokens = lexer.tokenize();

      print('Input: $basicCode');
      print('Token count: ${tokens.length}');

      // Zeige wichtige Tokens
      for (final token in tokens) {
        if (token.type != TokenType.whitespace &&
            token.type != TokenType.newline) {
          print('  ${token.type}: "${token.value}"');
        }
      }

      // Assertions
      expect(tokens.first.type, equals(TokenType.flowchart));
      expect(
        tokens.where((t) => t.type == TokenType.arrow).length,
        greaterThan(0),
      );
      expect(
        tokens.where((t) => t.type == TokenType.leftBracket).length,
        equals(4),
      );
    });

    test('Test 2) New Shape Syntax with @{shape...}', () {
      print('\n=== Test 2: New Shape Syntax ===');

      const newShapeCode = '''
flowchart LR
  A@{shape: circle, label: "Start"} --> B@{shape: rect, label: "Process"}
  B --> C@{shape: diamond, label: "Decision?"}
  C --> D@{shape: stadium, label: "End"}
''';

      final lexer = MermaidLexer(newShapeCode);
      final tokens = lexer.tokenize();

      print('Input: $newShapeCode');
      print('Token count: ${tokens.length}');

      // Zeige alle relevanten Tokens
      for (final token in tokens) {
        if (token.type != TokenType.whitespace &&
            token.type != TokenType.newline) {
          print('  ${token.type}: "${token.value}"');
        }
      }

      // Assertions für neue Syntax
      expect(tokens.where((t) => t.type == TokenType.at).length, equals(4));
      expect(tokens.where((t) => t.type == TokenType.shape).length, equals(4));
      expect(tokens.where((t) => t.type == TokenType.label).length, equals(4));
      expect(tokens.where((t) => t.type == TokenType.circle).length, equals(1));
      expect(tokens.where((t) => t.type == TokenType.rect).length, equals(1));
      expect(
        tokens.where((t) => t.type == TokenType.diamond).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.stadium).length,
        equals(1),
      );
    });

    test('Test 3) All Connection Types Including Mixed Bidirectional', () {
      print(
        '\n=== Test 3: All Connection Types Including Mixed Bidirectional ===',
      );

      const connectionCode = '''
flowchart TD
  A --> B
  B --- C
  C -.-> D
  D -.- E
  E ==> F
  F === G
  G ~~~ H
  H --o I
  I --x J
  J <--> K
  K o--o L
  L x--x M
  M <--o N
  N <--x O
  O o--> P
  P x--> Q
  Q o--x R
  R x--o S
  S <-----> T
''';

      final lexer = MermaidLexer(connectionCode);
      final tokens = lexer.tokenize();

      print('Input: $connectionCode');

      // Zähle Connection-Types
      final connections = <TokenType, int>{};
      for (final token in tokens) {
        if ([
          TokenType.arrow,
          TokenType.line,
          TokenType.dottedArrow,
          TokenType.dottedLine,
          TokenType.thickArrow,
          TokenType.thickLine,
          TokenType.invisibleLink,
          TokenType.circleArrow,
          TokenType.crossArrow,
          TokenType.bidirectional,
          TokenType.bidirectionalCircle,
          TokenType.bidirectionalCross,
          TokenType.arrowToCircle,
          TokenType.arrowToCross,
          TokenType.circleToArrow,
          TokenType.crossToArrow,
          TokenType.circleToCross,
          TokenType.crossToCircle,
        ].contains(token.type)) {
          connections[token.type] = (connections[token.type] ?? 0) + 1;
          print('  ${token.type}: "${token.value}"');
        }
      }

      print('Connection summary: $connections');

      // Assertions für alle Verbindungstypen
      expect(connections[TokenType.arrow], equals(1));
      expect(connections[TokenType.line], equals(1));
      expect(connections[TokenType.dottedArrow], equals(1));
      expect(connections[TokenType.thickArrow], equals(1));
      expect(connections[TokenType.invisibleLink], equals(1));
      expect(connections[TokenType.circleArrow], equals(1));
      expect(connections[TokenType.crossArrow], equals(1));

      // Bidirektionale Verbindungen
      expect(connections[TokenType.bidirectional], equals(2)); // <-->
      expect(connections[TokenType.bidirectionalCircle], equals(1)); // o--o
      expect(connections[TokenType.bidirectionalCross], equals(1)); // x--x

      // Gemischte bidirektionale Verbindungen
      expect(connections[TokenType.arrowToCircle], equals(1)); // <--o
      expect(connections[TokenType.arrowToCross], equals(1)); // <--x
      expect(connections[TokenType.circleToArrow], equals(1)); // o-->
      expect(connections[TokenType.crossToArrow], equals(1)); // x-->
      expect(connections[TokenType.circleToCross], equals(1)); // o--x
      expect(connections[TokenType.crossToCircle], equals(1)); // x--o
    });

    test('Test 4) Shape Aliases and Variants', () {
      print('\n=== Test 4: Shape Aliases ===');

      const aliasCode = '''
flowchart TB
  A@{shape: database, label: "DB"} --> B@{shape: decision, label: "Check"}
  B --> C@{shape: process, label: "Handle"}
  C --> D@{shape: terminal, label: "Exit"}
  E@{shape: cylinder, label: "Storage"} --> F@{shape: hexagon, label: "Prepare"}
''';

      final lexer = MermaidLexer(aliasCode);
      final tokens = lexer.tokenize();

      print('Input: $aliasCode');

      // Zeige Shape-Tokens
      for (final token in tokens) {
        if ([
          TokenType.database,
          TokenType.decision,
          TokenType.process,
          TokenType.terminal,
          TokenType.cylinder,
          TokenType.hexagon,
        ].contains(token.type)) {
          print('  ${token.type}: "${token.value}"');
        }
      }

      // Assertions
      expect(
        tokens.where((t) => t.type == TokenType.database).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.decision).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.process).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.terminal).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.cylinder).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.hexagon).length,
        equals(1),
      );
    });

    test('Test 5) Mixed Classic and New Syntax', () {
      print('\n=== Test 5: Mixed Syntax ===');

      const mixedCode = '''
flowchart TD
  Start@{shape: sm-circ, label: "Begin"} --> A[Classic Rectangle]
  A --> Decision{Classic Diamond}
  Decision --> B@{shape: curv-trap, label: "Display Result"}
  Decision --> C(Classic Round)
  B --> End@{shape: dbl-circ, label: "Finish"}
  C --> End
  
  %% This is a comment
  classDef highlight fill:#f96,stroke:#333,stroke-width:2px
  class Start,End highlight
''';

      final lexer = MermaidLexer(mixedCode);
      final tokens = lexer.tokenize();

      print('Input: $mixedCode');

      // Kategorisiere Tokens
      final categories = <String, List<String>>{
        'Shapes': [],
        'Connections': [],
        'Brackets': [],
        'Special': [],
      };

      for (final token in tokens) {
        switch (token.type) {
          case TokenType.smCirc:
          case TokenType.curvTrap:
          case TokenType.dblCirc:
            categories['Shapes']!.add('${token.type}: "${token.value}"');
            break;
          case TokenType.arrow:
          case TokenType.line:
            categories['Connections']!.add('${token.type}: "${token.value}"');
            break;
          case TokenType.leftBracket:
          case TokenType.rightBracket:
          case TokenType.leftParen:
          case TokenType.rightParen:
          case TokenType.leftBrace:
          case TokenType.rightBrace:
            categories['Brackets']!.add('${token.type}: "${token.value}"');
            break;
          case TokenType.comment:
          case TokenType.classDef:
          case TokenType.class_:
            categories['Special']!.add('${token.type}: "${token.value}"');
            break;
          default:
            break;
        }
      }

      // Print categories
      categories.forEach((category, tokens) {
        if (tokens.isNotEmpty) {
          print('$category:');
          tokens.forEach((token) => print('  $token'));
        }
      });

      // Assertions
      expect(
        tokens.where((t) => t.type == TokenType.at).length,
        greaterThan(0),
      );
      expect(
        tokens.where((t) => t.type == TokenType.leftBracket).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.leftBrace).length,
        equals(4),
      ); // Mix of classic {} and new @{}
      expect(
        tokens.where((t) => t.type == TokenType.commentText).length,
        equals(1),
      );
    });

    test('Test 6) Complex Real-World Example', () {
      print('\n=== Test 6: Complex Real-World Example ===');

      const complexCode = '''
flowchart TD
  Start@{shape: circle, label: "🚀 Start Process"} --> Init[Initialize System]
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
  
  %% Styling
  classDef success fill:#d4edda,stroke:#155724,stroke-width:2px
  classDef error fill:#f8d7da,stroke:#721c24,stroke-width:2px
  classDef process fill:#cce5ff,stroke:#0066cc,stroke-width:2px
  
  class Success success
  class ShowError,End error
  class ProcessData,Transform process
''';

      final lexer = MermaidLexer(complexCode);
      final tokens = lexer.tokenize();

      print('Input length: ${complexCode.length} characters');
      print('Token count: ${tokens.length}');

      // Statistiken
      final stats = <TokenType, int>{};
      for (final token in tokens) {
        stats[token.type] = (stats[token.type] ?? 0) + 1;
      }

      print('\nToken Statistics:');
      stats.entries
          .where(
            (entry) =>
                entry.key != TokenType.whitespace &&
                entry.key != TokenType.newline,
          )
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(15)
        ..forEach((entry) {
          print('  ${entry.key}: ${entry.value}');
        });

      // Spezielle Checks
      final shapeTokens = tokens
          .where(
            (t) => [
              TokenType.circle,
              TokenType.doc,
              TokenType.cyl,
              TokenType.hCyl,
              TokenType.hex,
              TokenType.diam,
              TokenType.stadium,
              TokenType.trapB,
              TokenType.dblCirc,
            ].contains(t.type),
          )
          .length;

      final connectionTokens = tokens
          .where(
            (t) => [
              TokenType.arrow,
              TokenType.dottedArrow,
              TokenType.thickArrow,
              TokenType.invisibleLink,
            ].contains(t.type),
          )
          .length;

      print('\nSpecial counts:');
      print('  Shape tokens: $shapeTokens');
      print('  Connection tokens: $connectionTokens');
      print(
        '  @ symbols: ${tokens.where((t) => t.type == TokenType.at).length}',
      );
      print(
        '  Comments: ${tokens.where((t) => t.type == TokenType.comment).length}',
      );
      print(
        '  Quoted strings: ${tokens.where((t) => t.type == TokenType.text && t.value.contains(' ')).length}',
      );

      // Assertions
      expect(tokens.length, greaterThan(100)); // Should have many tokens
      expect(
        tokens.where((t) => t.type == TokenType.flowchart).length,
        equals(1),
      );
      expect(
        tokens.where((t) => t.type == TokenType.direction).length,
        equals(1),
      );
      expect(shapeTokens, equals(9)); // All the specified shapes
      expect(connectionTokens, greaterThan(10)); // Many connections
      expect(
        tokens.where((t) => t.type == TokenType.classDef).length,
        equals(3),
      );
    });

    test('Test 7) Error Handling - Invalid Syntax', () {
      print('\n=== Test 7: Error Handling ===');

      const invalidCode = '''
flowchart TD
  A@{shape: unknown-shape, label: "Test"} --> B
  C@{incomplete
  D"unterminated string
  E`unterminated markdown
''';

      final lexer = MermaidLexer(invalidCode);

      // Should not throw, but handle gracefully
      expect(() {
        final tokens = lexer.tokenize();
        print('Successfully tokenized ${tokens.length} tokens despite errors');

        // Print non-whitespace tokens
        for (final token in tokens.take(20)) {
          if (token.type != TokenType.whitespace &&
              token.type != TokenType.newline) {
            print('  ${token.type}: "${token.value}"');
          }
        }
      }, returnsNormally);
    });

    test('Test 8) FontAwesome and Special Characters', () {
      print('\n=== Test 8: FontAwesome & Special Characters ===');

      const specialCode = '''
flowchart LR
  A@{shape: circle, label: "fa:fa-user Start"} --> B[fa:fa-database Data]
  B --> C@{shape: hex, label: "Process"} & D["Validate & Test"]
  C --> D["Result: Success! 🎉"]
  
  E[Special chars: #hash @at ?question !exclamation] --> F
''';

      final lexer = MermaidLexer(specialCode);
      final tokens = lexer.tokenize();

      print('Input: $specialCode');

      // Zeige spezielle Tokens
      for (final token in tokens) {
        if ([
          TokenType.fontAwesome,
          TokenType.hash,
          TokenType.at,
          TokenType.question,
          TokenType.exclamation,
          TokenType.ampersand,
        ].contains(token.type)) {
          print('  ${token.type}: "${token.value}"');
        }
      }

      // Assertions
      expect(
        tokens.where((t) => t.type == TokenType.fontAwesome).length,
        greaterThan(0),
      );
      expect(
        tokens.where((t) => t.type == TokenType.hash).length,
        greaterThan(0),
      );
      expect(
        tokens.where((t) => t.type == TokenType.ampersand).length,
        equals(1),
      );
    });
  });
}
