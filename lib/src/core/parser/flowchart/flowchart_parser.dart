// =============================================================================
// MERMAID FLOWCHART PARSER
// =============================================================================

import 'flowchart_ast.dart';
import 'flowchart_lexer.dart';

export 'flowchart_ast.dart';
export 'flowchart_lexer.dart';

// =============================================================================
// MERMAID FLOWCHART PARSER
// =============================================================================

class MermaidFlowchartParser {
  MermaidFlowchartParser(this.tokens);

  final List<Token> tokens;
  int current = 0;

  /// Hauptmethod: Parst die Token-Liste zu einem FlowchartDocument
  FlowchartDocument parse() {
    final statements = <Statement>[];
    String? direction;

    // Parse flowchart directive und direction
    if (!isAtEnd() && check(TokenType.flowchart)) {
      advance(); // consume 'flowchart'

      if (!isAtEnd() && check(TokenType.direction)) {
        direction = advance().value;
      }
    } else if (!isAtEnd() && check(TokenType.graph)) {
      advance(); // consume 'graph'

      if (!isAtEnd() && check(TokenType.direction)) {
        direction = advance().value;
      }
    }

    // Parse statements
    while (!isAtEnd()) {
      try {
        skipWhitespaceAndNewlines();
        if (isAtEnd()) break;

        final parsedStatements = parseStatement();
        for (final statement in parsedStatements) {
          statements.add(statement);
          print('DEBUG Parser: Added statement: ${statement.runtimeType}');
        }

        // CRITICAL FIX: Nach jedem Statement, checke für hanging tokens
        skipWhitespaceAndNewlines();
      } catch (e) {
        print('DEBUG Parser: Error parsing statement: $e');
        // Skip problematic tokens and continue
        if (!isAtEnd()) advance();
      }
    }

    return FlowchartDocument(statements, direction: direction);
  }

  /// Parst ein einzelnes Statement
  List<Statement> parseStatement() {
    if (isAtEnd()) return [];

    final token = peek();

    switch (token.type) {
      // Style statements
      case TokenType.style:
        return [parseStyleStatement()];
      case TokenType.classDef:
        return [parseClassDefStatement()];
      case TokenType.class_:
        return [parseClassStatement()];
      case TokenType.click:
        return [parseClickStatement()];
      case TokenType.linkStyle:
        return [parseLinkStyleStatement()];

      // Subgraph
      case TokenType.subgraph:
        return [parseSubgraphStatement()];

      // Node oder Connection - FIXED: Returns multiple statements
      case TokenType.identifier:
        return parseNodeOrConnectionStatement();

      // Skip alle anderen Token (Brackets, etc. die nicht am Statement-Anfang stehen)
      default:
        advance(); // Skip token
        return [];
    }
  }

  /// Parst Node- oder Connection-Statement mit vollständiger Lookahead-Erkennung
  List<Statement> parseNodeOrConnectionStatement() {
    final statements = <Statement>[];

    final nodeId = advance().value; // consume node ID
    print(
      'DEBUG Parser: Processing nodeId="$nodeId", next token: ${isAtEnd() ? "END" : peek().type}',
    );

    // KORRIGIERT: Entferne frühe isAtEnd() Prüfung
    // Wir haben bereits eine nodeId, also sollten wir mindestens einen Node erstellen

    // Check für @{shape:...} Syntax
    if (!isAtEnd() && check(TokenType.at)) {
      print('DEBUG Parser: Found @ syntax for node $nodeId');
      statements.add(parseNewSyntaxNode(nodeId));
      return statements;
    }

    // Check für klassische Node-Syntax: A[Text], A(Text), A{Text}
    if (!isAtEnd() && (check(TokenType.leftBracket) ||
        check(TokenType.leftParen) ||
        check(TokenType.leftBrace))) {
      print(
        'DEBUG Parser: Found classic syntax for node $nodeId, bracket: ${peek().type}',
      );
      final node = parseClassicNode(nodeId);
      print(
        'DEBUG Parser: Parsed classic node: ${node.id} -> "${node.text}", next token: ${isAtEnd() ? "END" : peek().type}',
      );
      statements.add(node);

      // After parsing node, check for connection
      skipWhitespaceAndNewlines();
      if (!isAtEnd() && isConnectionToken()) {
        final connectionStatements = parseConnectionChain(nodeId);
        statements.addAll(connectionStatements);
      }

      return statements;
    }

    // Check für Connection: A --> B[Text] (vollständige Connection mit Target-Node-Definition)
    if (!isAtEnd() && isConnectionToken()) {
      print('DEBUG Parser: Found connection starting from $nodeId');
      final connectionStatements = parseConnectionChain(nodeId);
      statements.addAll(connectionStatements);
      return statements;
    }

    // Fallback: Simple node ohne Shape-Definition
    // KORRIGIERT: Wird jetzt auch bei isAtEnd() erreicht
    print('DEBUG Parser: Fallback simple node for $nodeId');
    statements.add(NodeStatement(nodeId, NodeShape.rectangle));
    return statements;
  }

  /// Parst eine Connection-Chain mit potentiellen Node-Definitionen
  List<Statement> parseConnectionChain(String fromId) {
    final statements = <Statement>[];

    while (!isAtEnd() && isConnectionToken()) {
      final connectionToken = advance(); // consume connection token
      print('DEBUG Parser: Connection token consumed: ${connectionToken.type}');

      skipWhitespaceAndNewlines();

      // FIXED: Handle connection labels |Label|
      String? connectionLabel;
      if (!isAtEnd() && check(TokenType.pipe)) {
        advance(); // consume first '|'

        // Sammle Label-Text zwischen | und |
        final labelTokens = <String>[];
        while (!isAtEnd() && !check(TokenType.pipe)) {
          labelTokens.add(advance().value);
        }

        if (check(TokenType.pipe)) {
          advance(); // consume closing '|'
          if (labelTokens.isNotEmpty) {
            connectionLabel = labelTokens.join(' ');
          }
        }

        skipWhitespaceAndNewlines();
      }

      // FIXED: Accept both identifier AND end as valid node IDs
      if (isAtEnd() ||
          (!check(TokenType.identifier) && !check(TokenType.end))) {
        throw ParseException(
          'Expected target node after connection',
          peek().line,
          peek().column,
        );
      }

      final toId = advance().value; // consume target node ID
      print(
        'DEBUG Parser: Target nodeId="$toId", next token: ${isAtEnd() ? "END" : peek().type}',
      );

      // Create connection with optional label
      final connectionType = mapTokenToConnectionType(connectionToken.type);
      statements.add(
        ConnectionStatement(
          fromId,
          toId,
          connectionType,
          label: connectionLabel,
        ),
      );
      print(
        'DEBUG Parser: Created connection: $fromId -> $toId (${connectionType}) ${connectionLabel != null ? 'label: "$connectionLabel"' : ''}',
      );

      // Check if target node has definition
      skipWhitespaceAndNewlines();

      // NEW: Check für @{shape: ...} Syntax
      if (!isAtEnd() && check(TokenType.at)) {
        print(
          'DEBUG Parser: Target node $toId has @ definition, parsing it...',
        );
        final targetNode = parseNewSyntaxNode(toId);
        statements.add(targetNode);
        print(
          'DEBUG Parser: Parsed target @-node: ${targetNode.id} -> "${targetNode.text}"',
        );
      }
      // Check für klassische Syntax: C[Text], C(Text), C{Text}
      else if (!isAtEnd() &&
          (check(TokenType.leftBracket) ||
              check(TokenType.leftParen) ||
              check(TokenType.leftBrace))) {
        print(
          'DEBUG Parser: Target node $toId has classic definition, parsing it...',
        );
        final targetNode = parseClassicNode(toId);
        statements.add(targetNode);
        print(
          'DEBUG Parser: Parsed target classic-node: ${targetNode.id} -> "${targetNode.text}"',
        );
      }

      // Continue with chain if there's another connection
      skipWhitespaceAndNewlines();
      // For now, break to avoid infinite loops
      break;
    }

    return statements;
  }

  /// Parst neue @{shape: circle, label: "Text"} Syntax
  NodeStatement parseNewSyntaxNode(String nodeId) {
    advance(); // consume '@'
    expect(TokenType.leftBrace); // consume '{'

    NodeShape? shape;
    String? text;
    FontAwesome? fontAwesome;
    final shapeParams = <String, dynamic>{};

    // Parse key-value pairs
    while (!isAtEnd() && !check(TokenType.rightBrace)) {
      if (check(TokenType.shape)) {
        advance(); // consume 'shape'
        expect(TokenType.colon); // consume ':'
        shape = parseShapeValue();
      } else if (check(TokenType.label)) {
        advance(); // consume 'label'
        expect(TokenType.colon); // consume ':'
        final labelToken = advance();
        text = labelToken.value;

        // Check für FontAwesome in label
        if (text.contains('fa:') == true) {
          final result = parseFontAwesome(text);
          fontAwesome = result.fontAwesome;
          text = result.cleanText;
        }
      }

      // Skip comma if present
      if (check(TokenType.comma)) {
        advance();
      }
    }

    expect(TokenType.rightBrace); // consume '}'

    return NodeStatement(
      nodeId,
      shape ?? NodeShape.rectangle,
      text: text,
      shapeParams: shapeParams.isNotEmpty ? shapeParams : null,
      fontAwesome: fontAwesome,
    );
  }

  String _getExpectedClosingToken(TokenType openingType) {
    switch (openingType) {
      case TokenType.leftBracket:
        return ']';
      case TokenType.leftParen:
        return ')';
      case TokenType.leftBrace:
        return '}';
      default:
        return 'closing token';
    }
  }

  /// Parst klassische Node-Syntax A[Text], A(Text), A{Text}
  NodeStatement parseClassicNode(String nodeId) {
    final shapeToken = advance(); // consume shape token

    // Determine shape from bracket type
    NodeShape shape;
    switch (shapeToken.type) {
      case TokenType.leftBracket:
        shape = NodeShape.rectangle;
        break;
      case TokenType.leftParen:
        shape = NodeShape.rounded;
        break;
      case TokenType.leftBrace:
        shape = NodeShape.rhombus;
        break;
      default:
        shape = NodeShape.rectangle;
    }

    String? text;
    FontAwesome? fontAwesome;

    // Parse content bis zum schließenden Token
    final contentTokens = <Token>[];
    while (!isAtEnd() && !isMatchingClosingToken(shapeToken.type)) {
      final token = advance();
      contentTokens.add(token);
    }

    // FIXED: Validiere dass schließendes Token existiert
    if (isAtEnd()) {
      final expectedClosing = _getExpectedClosingToken(shapeToken.type);
      throw ParseException(
          'Unterminated node definition, expected \'$expectedClosing\'',
          shapeToken.line,
          shapeToken.column
      );
    }

    // Consume closing token (wir wissen jetzt, dass es existiert)
    advance();

    // Process content tokens
    if (contentTokens.isNotEmpty) {
      // Check für FontAwesome
      if (contentTokens.isNotEmpty && contentTokens.first.type == TokenType.fontAwesome) {
        fontAwesome = FontAwesome(contentTokens.first.value.split(':').last);
        text = contentTokens.skip(1).map((t) => t.value).join(' ').trim();
      } else {
        // Kombiniere alle Tokens zu Text (inkl. Zahlen und Sonderzeichen)
        text = contentTokens.map((t) => t.value).join(' ').trim();

        // Check für FontAwesome in text und bereinige Text
        if (text.contains('fa:') == true) {
          final result = parseFontAwesome(text);
          fontAwesome = result.fontAwesome;
          text = result.cleanText;
        }
      }

      // Leere Strings zu null
      if (text.isEmpty == true) {
        text = null;
      }
    }

    return NodeStatement(nodeId, shape, text: text, fontAwesome: fontAwesome);
  }

  /// Parst Connection zwischen Nodes
  Statement parseConnection(String fromId) {
    final connectionToken = advance(); // consume connection token
    print('DEBUG Parser: Connection token consumed: ${connectionToken.type}');

    skipWhitespaceAndNewlines();

    if (isAtEnd()) {
      throw ParseException(
        'Expected target node after connection',
        peek().line,
        peek().column,
      );
    }

    if (!check(TokenType.identifier)) {
      throw ParseException(
        'Expected target node identifier after connection',
        peek().line,
        peek().column,
      );
    }

    final toId = advance().value; // consume target node ID
    print(
      'DEBUG Parser: Target nodeId="$toId", next token: ${isAtEnd() ? "END" : peek().type}',
    );

    // Map TokenType to ConnectionType
    final connectionType = mapTokenToConnectionType(connectionToken.type);

    // CRITICAL FIX: Check if target node has a definition following
    skipWhitespaceAndNewlines();
    if (!isAtEnd() &&
        (check(TokenType.leftBracket) ||
            check(TokenType.leftParen) ||
            check(TokenType.leftBrace))) {
      print('DEBUG Parser: Target node $toId has definition, parsing it...');
      final targetNode = parseClassicNode(toId);
      print(
        'DEBUG Parser: Parsed target node: ${targetNode.id} -> "${targetNode.text}"',
      );

      // We need to return both the connection and the node
      // Since we can only return one Statement, we'll add the node to a pending list
      // or we need a different approach...

      // For now, let's create a compound statement or handle this differently
      // We'll return the connection and let the main loop handle the node definition
    }

    print(
      'DEBUG Parser: Created connection: $fromId -> $toId (${connectionType})',
    );

    return ConnectionStatement(fromId, toId, connectionType);
  }

  /// Parst Shape-Wert nach shape:
  NodeShape parseShapeValue() {
    if (isAtEnd()) return NodeShape.rectangle;

    final token = advance();
    return mapTokenToShape(token) ?? NodeShape.rectangle;
  }

  /// Parst FontAwesome aus String und entfernt es aus dem Text
  ({FontAwesome? fontAwesome, String cleanText}) parseFontAwesome(String text) {
    final faMatch = RegExp(r'fa:(fa-[\w-]+)').firstMatch(text);
    if (faMatch != null) {
      final fontAwesome = FontAwesome(faMatch.group(1)!);
      // FIXED: Entferne FontAwesome-Pattern aus Text
      final cleanText = text
          .replaceFirst(RegExp(r'fa:fa-[\w-]+\s*'), '')
          .trim();
      return (fontAwesome: fontAwesome, cleanText: cleanText);
    }
    return (fontAwesome: null, cleanText: text);
  }

  /// Parst Style Statement: style A fill:#f9f
  StyleStatement parseStyleStatement() {
    advance(); // consume 'style'

    final target = expect(TokenType.identifier).value;
    final properties = <String, String>{};

    // Parse style properties
    while (!isAtEnd() && !isStatementEnd()) {
      final prop = advance();
      if (check(TokenType.colon)) {
        advance(); // consume ':'

        // FIXED: Sammle vollständigen Wert (inkl. # + Hex-Werte)
        final valueTokens = <String>[];

        // Sammle alle zusammenhängenden Wert-Tokens bis Komma oder Statement-Ende
        while (!isAtEnd() && !check(TokenType.comma) && !isStatementEnd()) {
          final token = advance();
          valueTokens.add(token.value);

          // Nach einem Token prüfen ob Komma oder Ende folgt
          if (check(TokenType.comma) || isStatementEnd()) {
            break;
          }
        }

        final value = valueTokens.join(
          '',
        ); // Ohne Leerzeichen: "#" + "f9f" = "#f9f"
        properties[prop.value] = value;
      }

      // Skip comma if present
      if (check(TokenType.comma)) advance();
    }

    return StyleStatement(target, properties);
  }

  /// Parst ClassDef Statement: classDef className fill:#f9f
  ClassDefStatement parseClassDefStatement() {
    advance(); // consume 'classDef'

    final className = expect(TokenType.identifier).value;
    final properties = <String, String>{};

    // Parse properties similar to style
    while (!isAtEnd() && !isStatementEnd()) {
      final prop = advance();
      if (check(TokenType.colon)) {
        advance(); // consume ':'

        // FIXED: Sammle vollständigen Wert (inkl. # + Hex-Werte)
        final valueTokens = <String>[];

        // Sammle alle zusammenhängenden Wert-Tokens bis Komma oder Statement-Ende
        while (!isAtEnd() && !check(TokenType.comma) && !isStatementEnd()) {
          final token = advance();
          valueTokens.add(token.value);

          // Nach einem Token prüfen ob Komma oder Ende folgt
          if (check(TokenType.comma) || isStatementEnd()) {
            break;
          }
        }

        final value = valueTokens.join(
          '',
        ); // Ohne Leerzeichen: "#" + "ff0" = "#ff0"
        properties[prop.value] = value;
      }

      if (check(TokenType.comma)) advance();
    }

    return ClassDefStatement(className, properties);
  }

  /// Parst Class Statement: class A,B className
  ClassStatement parseClassStatement() {
    advance(); // consume 'class'

    final nodeIds = <String>[];

    // Parse comma-separated node IDs - FIXED: Accept 'end' as valid node ID
    do {
      if (check(TokenType.identifier) || check(TokenType.end)) {
        nodeIds.add(advance().value);
      } else {
        throw ParseException(
          'Expected node identifier in class statement',
          peek().line,
          peek().column,
        );
      }

      if (check(TokenType.comma)) {
        advance();
      } else {
        break;
      }
    } while (!isAtEnd());

    // FIXED: ClassName kann auch 'end' sein (als identifier)
    String className;
    if (check(TokenType.identifier) || check(TokenType.end)) {
      className = advance().value;
    } else {
      throw ParseException('Expected class name', peek().line, peek().column);
    }

    return ClassStatement(nodeIds, className);
  }

  /// Parst Click Statement: click A callback "tooltip"
  ClickStatement parseClickStatement() {
    advance(); // consume 'click'

    final nodeId = expect(TokenType.identifier).value;

    ClickAction action;
    String? tooltip;

    // FIXED: Check für verschiedene Action-Patterns
    if (!isAtEnd() && check(TokenType.text)) {
      // URL in Quotes: click B "https://example.com" "tooltip"
      final urlToken = advance();
      action = LinkAction(urlToken.value);
    } else if (!isAtEnd() && check(TokenType.identifier)) {
      final actionToken = advance();

      if (actionToken.value == 'call' &&
          !isAtEnd() &&
          check(TokenType.identifier)) {
        // call myFunction() pattern
        final functionToken = advance();

        // Skip optional parentheses: myFunction()
        if (!isAtEnd() && check(TokenType.leftParen)) {
          advance(); // consume '('
          if (!isAtEnd() && check(TokenType.rightParen)) {
            advance(); // consume ')'
          }
        }

        action = CallbackAction(functionToken.value, isCall: true);
      } else if (actionToken.value.startsWith('http')) {
        // URL without quotes: click B https://example.com "tooltip"
        action = LinkAction(actionToken.value);
      } else {
        // Regular callback: click A callback "tooltip"
        action = CallbackAction(actionToken.value);
      }
    } else {
      // Fallback
      final actionToken = advance();
      action = CallbackAction(actionToken.value);
    }

    // Parse tooltip (always in quotes)
    if (!isAtEnd() && check(TokenType.text)) {
      tooltip = advance().value;
    }

    return ClickStatement(nodeId, action, tooltip: tooltip);
  }

  /// Parst LinkStyle Statement: linkStyle 0 stroke:#f9f
  LinkStyleStatement parseLinkStyleStatement() {
    advance(); // consume 'linkStyle'

    final linkIndices = <int>[];

    // Parse comma-separated indices - FIXED: Auch text-Tokens als Zahlen behandeln
    do {
      final indexToken = advance();
      int index = 0;

      // FIXED: Handle sowohl number als auch identifier/text tokens
      if (indexToken.type == TokenType.number) {
        index = int.tryParse(indexToken.value) ?? 0;
      } else {
        // Falls als identifier/text geparst, versuche trotzdem zu konvertieren
        index = int.tryParse(indexToken.value) ?? 0;
      }

      linkIndices.add(index);

      if (check(TokenType.comma)) {
        advance(); // consume comma
      } else {
        break;
      }
    } while (!isAtEnd());

    final properties = <String, String>{};

    // Parse properties - FIXED: Gleiche Logik wie in style/classDef
    while (!isAtEnd() && !isStatementEnd()) {
      final prop = advance();
      if (check(TokenType.colon)) {
        advance(); // consume ':'

        // FIXED: Sammle vollständigen Wert (inkl. # + Hex-Werte)
        final valueTokens = <String>[];

        // Sammle alle zusammenhängenden Wert-Tokens bis Komma oder Statement-Ende
        while (!isAtEnd() && !check(TokenType.comma) && !isStatementEnd()) {
          final token = advance();
          valueTokens.add(token.value);

          // Nach einem Token prüfen ob Komma oder Ende folgt
          if (check(TokenType.comma) || isStatementEnd()) {
            break;
          }
        }

        final value = valueTokens.join(''); // "#" + "f9f" = "#f9f"
        properties[prop.value] = value;
      }

      if (check(TokenType.comma)) advance();
    }

    return LinkStyleStatement(linkIndices, properties);
  }

  /// Parst Subgraph Statement
  SubgraphStatement parseSubgraphStatement() {
    advance(); // consume 'subgraph'

    String? id;
    String? title;

    // Parse optional ID and title
    if (check(TokenType.identifier)) {
      id = advance().value;

      // FIXED: Parse title in brackets [Title can have multiple words]
      if (check(TokenType.leftBracket)) {
        advance(); // consume '['

        // Sammle alle Tokens zwischen [ und ]
        final titleTokens = <String>[];
        while (!isAtEnd() && !check(TokenType.rightBracket)) {
          final token = advance();
          titleTokens.add(token.value);
        }

        if (check(TokenType.rightBracket)) {
          advance(); // consume ']'

          if (titleTokens.isNotEmpty) {
            title = titleTokens.join(' '); // "Subgraph Title"
          }
        }
      }
    }

    final statements = <Statement>[];

    // Parse statements until 'end'
    while (!isAtEnd() && !check(TokenType.end)) {
      skipWhitespaceAndNewlines();
      if (isAtEnd() || check(TokenType.end)) break;

      final parsedStatements = parseStatement();
      statements.addAll(parsedStatements);
    }

    if (check(TokenType.end)) {
      advance(); // consume 'end'
    }

    return SubgraphStatement(statements, id: id, title: title);
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Maps TokenType zu NodeShape
  NodeShape? mapTokenToShape(Token token) {
    switch (token.type) {
      // Basic shapes
      case TokenType.circle:
        return NodeShape.circle;
      case TokenType.rect:
        return NodeShape.rectangle;
      case TokenType.stadium:
        return NodeShape.stadium;
      case TokenType.hex:
        return NodeShape.hexagon;
      case TokenType.diam:
        return NodeShape.diam;
      case TokenType.cyl:
        return NodeShape.cylinder;

      // FIXED: Extended shapes (alle aus der Lexer-Definition)
      case TokenType.smCirc:
        return NodeShape.smCirc;
      case TokenType.dblCirc:
        return NodeShape.dblCirc;
      case TokenType.frCirc:
        return NodeShape.frCirc;
      case TokenType.notchRect:
        return NodeShape.notchRect;
      case TokenType.hourglass:
        return NodeShape.hourglass;
      case TokenType.bolt:
        return NodeShape.bolt;
      case TokenType.brace:
        return NodeShape.brace;
      case TokenType.braceR:
        return NodeShape.braceR;
      case TokenType.braces:
        return NodeShape.braces;
      case TokenType.leanR:
        return NodeShape.leanR;
      case TokenType.leanL:
        return NodeShape.leanL;
      case TokenType.delay:
        return NodeShape.delay;
      case TokenType.hCyl:
        return NodeShape.hCyl;
      case TokenType.linCyl:
        return NodeShape.linCyl;
      case TokenType.curvTrap:
        return NodeShape.curvTrap;
      case TokenType.divRect:
        return NodeShape.divRect;
      case TokenType.doc:
        return NodeShape.doc;
      case TokenType.rounded:
        return NodeShape.rounded;
      case TokenType.tri:
        return NodeShape.tri;
      case TokenType.fork:
        return NodeShape.fork;
      case TokenType.winPane:
        return NodeShape.winPane;
      case TokenType.fCirc:
        return NodeShape.fCirc;
      case TokenType.linDoc:
        return NodeShape.linDoc;
      case TokenType.linRect:
        return NodeShape.linRect;
      case TokenType.notchPent:
        return NodeShape.notchPent;
      case TokenType.flipTri:
        return NodeShape.flipTri;
      case TokenType.slRect:
        return NodeShape.slRect;
      case TokenType.trapT:
        return NodeShape.trapT;
      case TokenType.trapB:
        return NodeShape.trapB;
      case TokenType.docs:
        return NodeShape.docs;
      case TokenType.stRect:
        return NodeShape.stRect;
      case TokenType.odd:
        return NodeShape.odd;
      case TokenType.flag:
        return NodeShape.flag;
      case TokenType.bowRect:
        return NodeShape.bowRect;
      case TokenType.frRect:
        return NodeShape.frRect;
      case TokenType.crossCirc:
        return NodeShape.crossCirc;
      case TokenType.tagDoc:
        return NodeShape.tagDoc;
      case TokenType.tagRect:
        return NodeShape.tagRect;
      case TokenType.textBlock:
        return NodeShape.textBlock;

      // Aliases
      case TokenType.diamond:
        return NodeShape.rhombus;
      case TokenType.database:
        return NodeShape.cylinder;
      case TokenType.process:
        return NodeShape.rectangle;
      case TokenType.decision:
        return NodeShape.rhombus;
      case TokenType.terminal:
        return NodeShape.stadium;
      case TokenType.start:
        return NodeShape.smCirc;
      case TokenType.stop:
        return NodeShape.frCirc;

      default:
        return null;
    }
  }

  /// Maps TokenType zu ConnectionType
  ConnectionType mapTokenToConnectionType(TokenType tokenType) {
    switch (tokenType) {
      case TokenType.arrow:
        return ConnectionType.arrow;
      case TokenType.line:
        return ConnectionType.line;
      case TokenType.dottedArrow:
        return ConnectionType.dottedArrow;
      case TokenType.dottedLine:
        return ConnectionType.dottedLine;
      case TokenType.thickArrow:
        return ConnectionType.thickArrow;
      case TokenType.thickLine:
        return ConnectionType.thickLine;
      case TokenType.invisibleLink:
        return ConnectionType.invisibleLink;
      case TokenType.circleArrow:
        return ConnectionType.circleArrow;
      case TokenType.crossArrow:
        return ConnectionType.crossArrow;
      case TokenType.bidirectional:
        return ConnectionType.bidirectional;
      case TokenType.bidirectionalCircle:
        return ConnectionType.bidirectionalCircle;
      case TokenType.bidirectionalCross:
        return ConnectionType.bidirectionalCross;
      case TokenType.arrowToCircle:
        return ConnectionType.arrowToCircle;
      case TokenType.arrowToCross:
        return ConnectionType.arrowToCross;
      case TokenType.circleToArrow:
        return ConnectionType.circleToArrow;
      case TokenType.crossToArrow:
        return ConnectionType.crossToArrow;
      case TokenType.circleToCross:
        return ConnectionType.circleToCross;
      case TokenType.crossToCircle:
        return ConnectionType.crossToCircle;
      default:
        return ConnectionType.arrow;
    }
  }

  /// Prüft ob Token ein Connection-Token ist
  bool isConnectionToken() {
    if (isAtEnd()) return false;

    final type = peek().type;
    return [
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
    ].contains(type);
  }

  /// Prüft ob aktueller Token zu schließendem Token passt
  bool isMatchingClosingToken(TokenType openingType) {
    if (isAtEnd()) return false;

    switch (openingType) {
      case TokenType.leftBracket:
        return check(TokenType.rightBracket);
      case TokenType.leftParen:
        return check(TokenType.rightParen);
      case TokenType.leftBrace:
        return check(TokenType.rightBrace);
      default:
        return false;
    }
  }

  /// Prüft ob Statement zu Ende ist (newline oder eof)
  bool isStatementEnd() {
    return isAtEnd() || check(TokenType.newline) || check(TokenType.eof);
  }

  /// Überspringt Whitespace und Newlines
  void skipWhitespaceAndNewlines() {
    while (!isAtEnd() &&
        (check(TokenType.whitespace) || check(TokenType.newline))) {
      advance();
    }
  }

  // =============================================================================
  // TOKEN NAVIGATION
  // =============================================================================

  /// Erwarte bestimmten TokenType
  Token expect(TokenType type) {
    if (check(type)) {
      return advance();
    }
    throw ParseException(
      'Expected $type but got ${peek().type}',
      peek().line,
      peek().column,
    );
  }

  /// Nächstes Token konsumieren
  Token advance() {
    if (!isAtEnd()) current++;
    return previous();
  }

  /// Prüfe TokenType ohne zu konsumieren
  bool check(TokenType type) {
    if (isAtEnd()) return false;
    return peek().type == type;
  }

  /// Aktuelles Token
  Token peek() => tokens[current];

  /// Vorheriges Token
  Token previous() => tokens[current - 1];

  /// Am Ende der Token-Liste?
  bool isAtEnd() => current >= tokens.length || peek().type == TokenType.eof;
}
