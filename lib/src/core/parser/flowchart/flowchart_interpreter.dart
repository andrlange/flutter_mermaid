// =============================================================================
// MERMAID FLOWCHART INTERPRETER - MAIN API
// =============================================================================

import 'flowchart_parser.dart';

export 'flowchart_ast.dart';

/// High-level API für das Parsen von Mermaid Flowchart Code
///
/// Kombiniert Lexer und Parser zu einer einfachen Schnittstelle
class MermaidFlowchartInterpreter {
  MermaidFlowchartInterpreter({this.enableDebugOutput = false});

  /// Aktiviert Debug-Output für Lexer und Parser
  final bool enableDebugOutput;

  /// Parst Mermaid Flowchart Code zu einem vollständigen AST
  ///
  /// [source] - Der Mermaid Flowchart Code als String
  ///
  /// Wirft [MermaidParseException] bei Parsing-Fehlern
  ///
  /// Beispiel:
  /// ```dart
  /// final interpreter = MermaidFlowchartInterpreter();
  /// final document = interpreter.parse('''
  ///   flowchart TD
  ///     A[Start] --> B{Decision}
  ///     B --> C[End]
  /// ''');
  /// ```
  FlowchartDocument parse(String source) {
    if (source.trim().isEmpty) {
      throw const MermaidParseException('Empty input provided');
    }

    try {
      // Phase 1: Lexical Analysis
      if (enableDebugOutput) {
        print('=== LEXER PHASE ===');
      }

      final lexer = MermaidLexer(source);
      final tokens = lexer.tokenize();

      if (enableDebugOutput) {
        print('Generated ${tokens.length} tokens');
        _printTokenSummary(tokens);
      }

      // Phase 2: Syntactic Analysis
      if (enableDebugOutput) {
        print('\n=== PARSER PHASE ===');
      }

      final parser = MermaidFlowchartParser(tokens);
      final document = parser.parse();

      if (enableDebugOutput) {
        print('Generated ${document.statements.length} statements');
        _printDocumentSummary(document);
      }

      // Phase 3: Validation
      _validateDocument(document);

      return document;

    } on ParseException catch (e) {
      throw MermaidParseException(
        'Parse error at line ${e.line}, column ${e.column}: ${e.message}',
        line: e.line,
        column: e.column,
        originalException: e,
      );
    } catch (e) {
      throw MermaidParseException(
        'Unexpected error during parsing: $e',
        originalException: e,
      );
    }
  }

  /// Parst Code und gibt detaillierte Parsing-Informationen zurück
  MermaidParseResult parseWithDetails(String source) {
    final stopwatch = Stopwatch()..start();

    try {
      final document = parse(source);
      stopwatch.stop();

      return MermaidParseResult(
        document: document,
        success: true,
        parsingTimeMs: stopwatch.elapsedMilliseconds,
        tokenCount: _countTokens(source),
        warnings: _validateAndGetWarnings(document),
      );
    } catch (e) {
      stopwatch.stop();

      return MermaidParseResult(
        document: null,
        success: false,
        error: e.toString(),
        parsingTimeMs: stopwatch.elapsedMilliseconds,
        tokenCount: _countTokens(source),
      );
    }
  }

  /// Validiert ein FlowchartDocument und wirft bei Problemen
  void _validateDocument(FlowchartDocument document) {
    // Check for empty document
    if (document.statements.isEmpty) {
      throw const MermaidParseException('Document contains no statements');
    }

    // Check for nodes without connections (warnings, not errors)
    final nodeStatements = document.statements.whereType<NodeStatement>();
    final connectionStatements = document.statements.whereType<ConnectionStatement>();

    if (nodeStatements.isNotEmpty && connectionStatements.isEmpty) {
      // This is allowed but might be intentional
    }

    // Validate connection references
    //final nodeIds = nodeStatements.map((n) => n.id).toSet();
    //for (final connection in connectionStatements) {
      // Note: We don't strictly require all referenced nodes to be defined
      // as they might be auto-created by connections
    //}
  }

  /// Sammelt Warnings für bessere UX
  List<String> _validateAndGetWarnings(FlowchartDocument document) {
    final warnings = <String>[];

    final nodeStatements = document.statements.whereType<NodeStatement>();
    final connectionStatements = document.statements.whereType<ConnectionStatement>();

    // Warning: Nodes ohne Connections
    final connectedNodeIds = <String>{};
    for (final conn in connectionStatements) {
      connectedNodeIds.add(conn.fromId);
      connectedNodeIds.add(conn.toId);
    }

    final isolatedNodes = nodeStatements
        .where((node) => !connectedNodeIds.contains(node.id))
        .map((node) => node.id)
        .toList();

    if (isolatedNodes.isNotEmpty) {
      warnings.add('Isolated nodes found: ${isolatedNodes.join(', ')}');
    }

    // Warning: Keine Direction definiert
    if (document.direction == null) {
      warnings.add('No direction specified, using default');
    }

    return warnings;
  }

  /// Zählt Tokens für Statistiken
  int _countTokens(String source) {
    try {
      final lexer = MermaidLexer(source);
      return lexer.tokenize().length;
    } catch (e) {
      return 0;
    }
  }

  /// Debug-Output: Token Summary
  void _printTokenSummary(List<Token> tokens) {
    final tokenCounts = <TokenType, int>{};
    for (final token in tokens) {
      tokenCounts[token.type] = (tokenCounts[token.type] ?? 0) + 1;
    }

    print('Token distribution:');
    final sortedEntries = tokenCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries.take(10)) {
      print('  ${entry.key}: ${entry.value}');
    }
  }

  /// Debug-Output: Document Summary
  void _printDocumentSummary(FlowchartDocument document) {
    final statementCounts = <Type, int>{};
    for (final statement in document.statements) {
      final type = statement.runtimeType;
      statementCounts[type] = (statementCounts[type] ?? 0) + 1;
    }

    print('Document structure:');
    print('  Direction: ${document.direction ?? 'default'}');
    print('  Statement distribution:');

    for (final entry in statementCounts.entries) {
      print('    ${entry.key}: ${entry.value}');
    }
  }
}

// =============================================================================
// PARSE RESULT UND EXCEPTIONS
// =============================================================================

/// Detailliertes Parsing-Ergebnis mit Metriken und Warnings
class MermaidParseResult {
  const MermaidParseResult({
    required this.success,
    required this.parsingTimeMs,
    required this.tokenCount,
    this.document,
    this.error,
    this.warnings = const [],
  });

  /// Ob das Parsing erfolgreich war
  final bool success;

  /// Das geparste Document (null bei Fehlern)
  final FlowchartDocument? document;

  /// Fehlermeldung (null bei Erfolg)
  final String? error;

  /// Parsing-Zeit in Millisekunden
  final int parsingTimeMs;

  /// Anzahl generierter Tokens
  final int tokenCount;

  /// Warnings die während des Parsings aufgetreten sind
  final List<String> warnings;

  @override
  String toString() => success
      ? 'Success: ${document!.statements.length} statements in ${parsingTimeMs}ms'
      : 'Error: $error';
}

/// Spezifische Exception für Mermaid Parsing-Fehler
class MermaidParseException implements Exception {
  const MermaidParseException(
      this.message, {
        this.line,
        this.column,
        this.originalException,
      });

  final String message;
  final int? line;
  final int? column;
  final dynamic originalException;

  @override
  String toString() {
    final location = (line != null && column != null)
        ? ' at line $line, column $column'
        : '';
    return 'MermaidParseException: $message$location';
  }
}