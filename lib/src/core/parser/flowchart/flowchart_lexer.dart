// =============================================================================
// ERWEITERTE LEXER MIT SHAPE-UNTERSTÜTZUNG
// =============================================================================

import 'package:flutter/foundation.dart';

enum TokenType {
  // Grundlegende Tokens
  identifier,
  text,
  newline,
  whitespace,
  commentText,
  number,

  // Direktiven
  flowchart,
  graph,
  subgraph,
  end,

  // Richtungen
  direction, // TD, TB, BT, RL, LR

  // Node-Formen (klassisch)
  leftBracket,     // [
  rightBracket,    // ]
  leftParen,       // (
  rightParen,      // )
  leftBrace,       // {
  rightBrace,      // }
  leftAngle,       // >

  // Shape-Keywords (alle aus der Tabelle)
  shape,           // Für @{shape: ...} Syntax
  label,           // Für label: "..." Syntax

  // Shape-Namen (Short Names)
  notchRect,       // notch-rect
  hourglass,       // hourglass
  bolt,            // bolt
  brace,           // brace
  braceR,          // brace-r
  braces,          // braces
  leanR,           // lean-r
  leanL,           // lean-l
  cyl,             // cyl
  diam,            // diam
  delay,           // delay
  hCyl,            // h-cyl
  linCyl,          // lin-cyl
  curvTrap,        // curv-trap
  divRect,         // div-rect
  doc,             // doc
  rounded,         // rounded
  tri,             // tri
  fork,            // fork
  winPane,         // win-pane
  fCirc,           // f-circ
  linDoc,          // lin-doc
  linRect,         // lin-rect
  notchPent,       // notch-pent
  flipTri,         // flip-tri
  slRect,          // sl-rect
  trapT,           // trap-t
  docs,            // docs
  stRect,          // st-rect
  odd,             // odd
  flag,            // flag
  hex,             // hex
  trapB,           // trap-b
  rect,            // rect
  circle,          // circle
  smCirc,          // sm-circ
  dblCirc,         // dbl-circ
  frCirc,          // fr-circ
  bowRect,         // bow-rect
  frRect,          // fr-rect
  crossCirc,       // cross-circ
  tagDoc,          // tag-doc
  tagRect,         // tag-rect
  stadium,         // stadium
  textBlock,       // text

  // Aliases (häufig verwendete)
  card,            // alias für notch-rect
  collate,         // alias für hourglass
  comLink,         // alias für bolt
  comment,         // alias für brace
  inOut,           // alias für lean-r
  leanRight,       // alias für lean-r
  leanLeft,        // alias für lean-l
  outIn,           // alias für lean-l
  cylinder,        // alias für cyl
  database,        // alias für cyl
  db,              // alias für cyl
  decision,        // alias für diam
  diamond,         // alias für diam
  question,        // alias für diam
  horizontalCylinder, // alias für h-cyl
  das,             // alias für h-cyl
  disk,            // alias für lin-cyl
  linedCylinder,   // alias für lin-cyl
  curvedTrapezoid, // alias für curv-trap
  display,         // alias für curv-trap
  dividedProcess,  // alias für div-rect
  dividedRectangle, // alias für div-rect
  divProc,         // alias für div-rect
  document,        // alias für doc
  event,           // alias für rounded
  extract,         // alias für tri
  triangle,        // alias für tri
  join,            // alias für fork
  internalStorage, // alias für win-pane
  windowPane,      // alias für win-pane
  filledCircle,    // alias für f-circ
  junction,        // alias für f-circ
  linedDocument,   // alias für lin-doc
  linedRectangle,  // alias für lin-rect
  linProc,         // alias für lin-rect
  linedProcess,    // alias für lin-rect
  shadedProcess,   // alias für lin-rect
  loopLimit,       // alias für notch-pent
  notchedPentagon, // alias für notch-pent
  flippedTriangle, // alias für flip-tri
  manualFile,      // alias für flip-tri
  slopedRectangle, // alias für sl-rect
  manualInput,     // alias für sl-rect
  invTrapezoid,    // alias für trap-t
  manual,          // alias für trap-t
  trapezoidTop,    // alias für trap-t
  documents,       // alias für docs
  multiDocument,   // alias für docs
  stackedDocument, // alias für docs
  stDoc,           // alias für docs
  processes,       // alias für st-rect
  procs,           // alias für st-rect
  multiProcess,    // alias für st-rect
  stackedRectangle, // alias für st-rect
  paperTape,       // alias für flag
  hexagon,         // alias für hex
  prepare,         // alias für hex
  priority,        // alias für trap-b
  trapezoid,       // alias für trap-b
  trapezoidBottom, // alias für trap-b
  proc,            // alias für rect
  process,         // alias für rect
  rectangle,       // alias für rect
  circ,            // alias für circle
  smallCircle,     // alias für sm-circ
  start,           // alias für sm-circ
  doubleCircle,    // alias für dbl-circ
  framedCircle,    // alias für fr-circ
  stop,            // alias für fr-circ
  bowTieRectangle, // alias für bow-rect
  storedData,      // alias für bow-rect
  framedRectangle, // alias für fr-rect
  subproc,         // alias für fr-rect
  subprocess,      // alias für fr-rect
  subroutine,      // alias für fr-rect
  crossedCircle,   // alias für cross-circ
  summary,         // alias für cross-circ
  taggedDocument,  // alias für tag-doc
  taggedProcess,   // alias für tag-rect
  tagProc,         // alias für tag-rect
  taggedRectangle, // alias für tag-rect
  pill,            // alias für stadium
  terminal,        // alias für stadium

  // Verbindungen - Basis
  arrow,           // -->
  line,            // ---
  dottedArrow,     // -.->
  dottedLine,      // -.-
  thickArrow,      // ==>
  thickLine,       // ===
  invisibleLink,   // ~~~

  // Verbindungen - Erweitert
  circleArrow,     // --o
  crossArrow,      // --x
  bidirectional,   // <-->
  bidirectionalArrow, // <--> (alias)
  bidirectionalCircle, // o--o
  bidirectionalCross,  // x--x

  // Gemischte bidirektionale Verbindungen
  arrowToCircle,   // <--o
  arrowToCross,    // <--x
  circleToArrow,   // o-->
  crossToArrow,    // x-->
  circleToCross,       // o--x
  crossToCircle,       // x--o

  // Pipes und Labels
  pipe,            // |
  quote,           // "
  backtick,        // `

  // Styling und Klassen
  classDef,
  class_,
  linkStyle,
  style,
  click,

  // Spezielle Zeichen
  colon,           // :
  semicolon,       // ;
  at,              // @
  ampersand,       // &
  hash,            // #
  questionMark,    // ?
  exclamation,     // !
  comma,           // ,

  // FontAwesome
  fontAwesome,     // fa:fa-icon

  // Markdown
  markdownText,    // "`text`"

  // EOF
  eof,
}

@immutable
class Token {
  const Token(this.type, this.value, this.line, this.column, this.position);
  final TokenType type;
  final String value;
  final int line;
  final int column;
  final int position;

  @override
  String toString() => '\nToken:\n  Type: $type\n  Value: $value\n  '
      'Line:  $line\n  Column:  $column\n)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Token &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(type, value);
}

// =============================================================================
// ERWEITERTE LEXER MIT SHAPE-UNTERSTÜTZUNG
// =============================================================================

class MermaidLexer {
  MermaidLexer(this.source);
  final String source;
  int position = 0;
  int line = 1;
  int column = 1;

  // Context tracking für @{shape: ...} Syntax
  bool _inShapeContext = false;
  int _braceDepth = 0;

  // Shape Keywords Map für effiziente Lookups
  static final Map<String, TokenType> _shapeKeywords = {
    // Shape-Syntax Keywords
    'shape': TokenType.shape,
    'label': TokenType.label,

    // Short Names (mit Bindestrich normalisiert zu Camelcase)
    'notch-rect': TokenType.notchRect,
    'notchrect': TokenType.notchRect,
    'hourglass': TokenType.hourglass,
    'bolt': TokenType.bolt,
    'brace': TokenType.brace,
    'brace-r': TokenType.braceR,
    'bracer': TokenType.braceR,
    'braces': TokenType.braces,
    'lean-r': TokenType.leanR,
    'leanr': TokenType.leanR,
    'lean-l': TokenType.leanL,
    'leanl': TokenType.leanL,
    'cyl': TokenType.cyl,
    'diam': TokenType.diam,
    'delay': TokenType.delay,
    'h-cyl': TokenType.hCyl,
    'hcyl': TokenType.hCyl,
    'lin-cyl': TokenType.linCyl,
    'lincyl': TokenType.linCyl,
    'curv-trap': TokenType.curvTrap,
    'curvtrap': TokenType.curvTrap,
    'div-rect': TokenType.divRect,
    'divrect': TokenType.divRect,
    'doc': TokenType.doc,
    'rounded': TokenType.rounded,
    'tri': TokenType.tri,
    'fork': TokenType.fork,
    'win-pane': TokenType.winPane,
    'winpane': TokenType.winPane,
    'f-circ': TokenType.fCirc,
    'fcirc': TokenType.fCirc,
    'lin-doc': TokenType.linDoc,
    'lindoc': TokenType.linDoc,
    'lin-rect': TokenType.linRect,
    'linrect': TokenType.linRect,
    'notch-pent': TokenType.notchPent,
    'notchpent': TokenType.notchPent,
    'flip-tri': TokenType.flipTri,
    'fliptri': TokenType.flipTri,
    'sl-rect': TokenType.slRect,
    'slrect': TokenType.slRect,
    'trap-t': TokenType.trapT,
    'trapt': TokenType.trapT,
    'docs': TokenType.docs,
    'st-rect': TokenType.stRect,
    'strect': TokenType.stRect,
    'odd': TokenType.odd,
    'flag': TokenType.flag,
    'hex': TokenType.hex,
    'trap-b': TokenType.trapB,
    'trapb': TokenType.trapB,
    'rect': TokenType.rect,
    'circle': TokenType.circle,
    'sm-circ': TokenType.smCirc,
    'smcirc': TokenType.smCirc,
    'dbl-circ': TokenType.dblCirc,
    'dblcirc': TokenType.dblCirc,
    'fr-circ': TokenType.frCirc,
    'frcirc': TokenType.frCirc,
    'bow-rect': TokenType.bowRect,
    'bowrect': TokenType.bowRect,
    'fr-rect': TokenType.frRect,
    'frrect': TokenType.frRect,
    'cross-circ': TokenType.crossCirc,
    'crosscirc': TokenType.crossCirc,
    'tag-doc': TokenType.tagDoc,
    'tagdoc': TokenType.tagDoc,
    'tag-rect': TokenType.tagRect,
    'tagrect': TokenType.tagRect,
    'stadium': TokenType.stadium,
    'text': TokenType.textBlock,

    // Aliases
    'card': TokenType.card,
    'notched-rectangle': TokenType.card,
    'collate': TokenType.collate,
    'com-link': TokenType.comLink,
    'lightning-bolt': TokenType.comLink,
    'comment': TokenType.comment,
    'in-out': TokenType.inOut,
    'lean-right': TokenType.leanRight,
    'lean-left': TokenType.leanLeft,
    'out-in': TokenType.outIn,
    'cylinder': TokenType.cylinder,
    'database': TokenType.database,
    'db': TokenType.db,
    'decision': TokenType.decision,
    'diamond': TokenType.diamond,
    'question': TokenType.question,
    'horizontal-cylinder': TokenType.horizontalCylinder,
    'das': TokenType.das,
    'disk': TokenType.disk,
    'lined-cylinder': TokenType.linedCylinder,
    'curved-trapezoid': TokenType.curvedTrapezoid,
    'display': TokenType.display,
    'div-proc': TokenType.divProc,
    'divided-process': TokenType.dividedProcess,
    'divided-rectangle': TokenType.dividedRectangle,
    'document': TokenType.document,
    'event': TokenType.event,
    'extract': TokenType.extract,
    'triangle': TokenType.triangle,
    'join': TokenType.join,
    'internal-storage': TokenType.internalStorage,
    'window-pane': TokenType.windowPane,
    'filled-circle': TokenType.filledCircle,
    'junction': TokenType.junction,
    'lined-document': TokenType.linedDocument,
    'lin-proc': TokenType.linProc,
    'lined-process': TokenType.linedProcess,
    'lined-rectangle': TokenType.linedRectangle,
    'shaded-process': TokenType.shadedProcess,
    'loop-limit': TokenType.loopLimit,
    'notched-pentagon': TokenType.notchedPentagon,
    'flipped-triangle': TokenType.flippedTriangle,
    'manual-file': TokenType.manualFile,
    'sloped-rectangle': TokenType.slopedRectangle,
    'manual-input': TokenType.manualInput,
    'inv-trapezoid': TokenType.invTrapezoid,
    'manual': TokenType.manual,
    'trapezoid-top': TokenType.trapezoidTop,
    'documents': TokenType.documents,
    'multi-document': TokenType.multiDocument,
    'stacked-document': TokenType.stackedDocument,
    'st-doc': TokenType.stDoc,
    'processes': TokenType.processes,
    'procs': TokenType.procs,
    'multi-process': TokenType.multiProcess,
    'stacked-rectangle': TokenType.stackedRectangle,
    'paper-tape': TokenType.paperTape,
    'hexagon': TokenType.hexagon,
    'prepare': TokenType.prepare,
    'priority': TokenType.priority,
    'trapezoid': TokenType.trapezoid,
    'trapezoid-bottom': TokenType.trapezoidBottom,
    'proc': TokenType.proc,
    'process': TokenType.process,
    'rectangle': TokenType.rectangle,
    'circ': TokenType.circ,
    'small-circle': TokenType.smallCircle,
    'start': TokenType.start,
    'double-circle': TokenType.doubleCircle,
    'framed-circle': TokenType.framedCircle,
    'stop': TokenType.stop,
    'bow-tie-rectangle': TokenType.bowTieRectangle,
    'stored-data': TokenType.storedData,
    'framed-rectangle': TokenType.framedRectangle,
    'subproc': TokenType.subproc,
    'subprocess': TokenType.subprocess,
    'subroutine': TokenType.subroutine,
    'crossed-circle': TokenType.crossedCircle,
    'summary': TokenType.summary,
    'tagged-document': TokenType.taggedDocument,
    'tag-proc': TokenType.tagProc,
    'tagged-process': TokenType.taggedProcess,
    'tagged-rectangle': TokenType.taggedRectangle,
    'pill': TokenType.pill,
    'terminal': TokenType.terminal,
  };

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!isAtEnd()) {
      try {
        final token = nextToken();
        if (token != null) {
          tokens.add(token);
        }
      } catch (e) {
        // Skip problematic characters und continue
        advance();
      }
    }

    tokens.add(Token(TokenType.eof, '', line, column, position));
    return tokens;
  }

  Token? nextToken() {
    skipWhitespace();

    if (isAtEnd()) return null;

    final start = position;
    final startLine = line;
    final startColumn = column;
    final char = advance();

    // Kommentare
    if (char == '%' && peek() == '%') {
      return scanComment(start, startLine, startColumn);
    }

    // Strings in Anführungszeichen
    if (char == '"') {
      return scanQuotedString(start, startLine, startColumn);
    }

    // Markdown strings mit Backticks
    if (char == '`') {
      return scanMarkdownString(start, startLine, startColumn);
    }

    // Verbindungen und Pfeile
    if (char == '-') {
      return scanConnection(start, startLine, startColumn);
    }

    if (char == '=') {
      return scanThickConnection(start, startLine, startColumn);
    }

    if (char == '~') {
      return scanInvisibleConnection(start, startLine, startColumn);
    }

    if (char == '<') {
      return scanBidirectionalConnection(start, startLine, startColumn, '<');
    }

    if (char == 'o') {
      return scanBidirectionalConnection(start, startLine, startColumn, 'o');
    }

    if (char == 'x') {
      return scanBidirectionalConnection(start, startLine, startColumn, 'x');
    }

    // Einzelne Zeichen - ERWEITERT
    switch (char) {
      case '[': return Token(TokenType.leftBracket, char, startLine, startColumn, start);
      case ']': return Token(TokenType.rightBracket, char, startLine, startColumn, start);
      case '(': return Token(TokenType.leftParen, char, startLine, startColumn, start);
      case ')': return Token(TokenType.rightParen, char, startLine, startColumn, start);
      case '{':
        _braceDepth++;
        return Token(TokenType.leftBrace, char, startLine, startColumn, start);
      case '}':
        _braceDepth--;
        if (_braceDepth == 0) _inShapeContext = false;
        return Token(TokenType.rightBrace, char, startLine, startColumn, start);
      case '>': return Token(TokenType.leftAngle, char, startLine, startColumn, start);
      case '|': return Token(TokenType.pipe, char, startLine, startColumn, start);
      case ':':
      // Context-Update: Nach "shape:" sind wir im Shape-Context
        if (_braceDepth > 0) _inShapeContext = true;
        return Token(TokenType.colon, char, startLine, startColumn, start);
      case ';': return Token(TokenType.semicolon, char, startLine, startColumn, start);
      case '@': return Token(TokenType.at, char, startLine, startColumn, start);
      case '&': return Token(TokenType.ampersand, char, startLine, startColumn, start);
      case '#': return Token(TokenType.hash, char, startLine, startColumn, start);
      case '?': return Token(TokenType.questionMark, char, startLine,
          startColumn, start);
      case '!': return Token(TokenType.exclamation, char, startLine, startColumn, start);
      case ',':
      // Nach Komma sind wir raus aus dem Shape-Context
        if (_braceDepth > 0) _inShapeContext = false;
        return Token(TokenType.comma, char, startLine, startColumn, start);
      case '\n':
        line++;
        column = 1;
        return Token(TokenType.newline, char, startLine, startColumn, start);
    }

    // Identifiers und Keywords (inkl. Shapes)
    if (isAlpha(char) || char == '_') {
      return scanIdentifier(start, startLine, startColumn);
    }

    // Zahlen (für Node-IDs und Styling)
    if (isDigit(char)) {
      return scanNumber(start, startLine, startColumn);
    }

    // FALLBACK: Behandle unbekannte Zeichen als Text
    return Token(TokenType.text, char, startLine, startColumn, start);
  }

  // SCAN-METHODEN (unverändert)
  Token scanComment(int start, int startLine, int startColumn) {
    advance(); // zweites %
    while (!isAtEnd() && peek() != '\n') {
      advance();
    }

    final value = source.substring(start, position);
    return Token(TokenType.commentText, value, startLine, startColumn, start);
  }

  Token scanQuotedString(int start, int startLine, int startColumn) {
    while (!isAtEnd() && peek() != '"') {
      if (peek() == '\\') {
        advance(); // Skip escape character
        if (!isAtEnd()) advance(); // Skip escaped character
      } else {
        if (peek() == '\n') line++;
        advance();
      }
    }

    if (isAtEnd()) {
      throw ParseException('Unterminated string', startLine, startColumn);
    }

    advance(); // closing "
    final value = source.substring(start + 1, position - 1); // ohne Anführungszeichen
    return Token(TokenType.text, value, startLine, startColumn, start);
  }

  Token scanMarkdownString(int start, int startLine, int startColumn) {
    while (!isAtEnd() && peek() != '`') {
      if (peek() == '\n') line++;
      advance();
    }

    if (isAtEnd()) {
      throw ParseException('Unterminated markdown string', startLine, startColumn);
    }

    advance(); // closing `
    final value = source.substring(start + 1, position - 1); // ohne Backticks
    return Token(TokenType.markdownText, value, startLine, startColumn, start);
  }

  Token scanConnection(int start, int startLine, int startColumn) {
    // Sammle alle '-' Zeichen
    while (!isAtEnd() && peek() == '-') {
      advance();
    }

    // Check für spezielle Endings
    if (!isAtEnd()) {
      final nextChar = peek();

      // Dotted connections: -.->, -.-
      if (nextChar == '.') {
        advance(); // consume '.'
        if (!isAtEnd() && peek() == '-') {
          while (!isAtEnd() && peek() == '-') {
            advance();
          }
          if (!isAtEnd() && peek() == '>') {
            advance();
            return Token(TokenType.dottedArrow, source.substring(start, position), startLine, startColumn, start);
          }
          return Token(TokenType.dottedLine, source.substring(start, position), startLine, startColumn, start);
        }
      }

      // Arrow ending: -->
      if (nextChar == '>') {
        advance();
        return Token(TokenType.arrow, source.substring(start, position), startLine, startColumn, start);
      }

      // Circle ending: --o
      if (nextChar == 'o') {
        advance();
        return Token(TokenType.circleArrow, source.substring(start, position), startLine, startColumn, start);
      }

      // Cross ending: --x
      if (nextChar == 'x') {
        advance();
        return Token(TokenType.crossArrow, source.substring(start, position), startLine, startColumn, start);
      }
    }

    // Plain line
    return Token(TokenType.line, source.substring(start, position), startLine, startColumn, start);
  }

  Token scanThickConnection(int start, int startLine, int startColumn) {
    // Sammle alle '=' Zeichen
    while (!isAtEnd() && peek() == '=') {
      advance();
    }

    // Check für arrow ending: ==>
    if (!isAtEnd() && peek() == '>') {
      advance();
      return Token(TokenType.thickArrow, source.substring(start, position), startLine, startColumn, start);
    }

    // Plain thick line
    return Token(TokenType.thickLine, source.substring(start, position), startLine, startColumn, start);
  }

  Token scanInvisibleConnection(int start, int startLine, int startColumn) {
    // Erwarte mindestens ~~~
    if (peek() == '~' && peekAhead(1) == '~') {
      advance(); // zweites ~
      advance(); // drittes ~

      // Sammle weitere ~
      while (!isAtEnd() && peek() == '~') {
        advance();
      }

      return Token(TokenType.invisibleLink, source.substring(start, position), startLine, startColumn, start);
    }

    // Einzelnes ~ behandeln als normales Zeichen
    return Token(TokenType.text, '~', startLine, startColumn, start);
  }

  Token scanBidirectionalConnection(int start, int startLine, int startColumn, String startChar) {
    // Sammle alle '-' Zeichen
    int dashCount = 0;
    while (!isAtEnd() && peek() == '-') {
      advance();
      dashCount++;
    }

    // Mindestens 2 Striche erforderlich für bidirektionale Verbindungen
    if (dashCount < 2) {
      // Fallback: startChar als normales Zeichen
      return Token(TokenType.text, startChar, startLine, startColumn, start);
    }

    // Check für End-Token
    if (!isAtEnd()) {
      final endChar = peek();

      if (endChar == '>' || endChar == 'o' || endChar == 'x') {
        advance(); // consume end char

        final fullPattern = source.substring(start, position);
        final tokenType = _getBidirectionalTokenType(startChar, endChar);

        return Token(tokenType, fullPattern, startLine, startColumn, start);
      }
    }

    // Fallback: Unvollständiges Pattern
    return Token(TokenType.text, source.substring(start, position), startLine, startColumn, start);
  }

  TokenType _getBidirectionalTokenType(String startChar, String endChar) {
    switch ('$startChar$endChar') {
    // Symmetrische Verbindungen
      case '<>': return TokenType.bidirectional;    // <-->
      case 'oo': return TokenType.bidirectionalCircle; // o--o
      case 'xx': return TokenType.bidirectionalCross;  // x--x

    // Gemischte Verbindungen (Pfeil zu anderen)
      case '<o': return TokenType.arrowToCircle;   // <--o
      case '<x': return TokenType.arrowToCross;    // <--x

    // Andere zu Pfeil
      case 'o>': return TokenType.circleToArrow;   // o-->
      case 'x>': return TokenType.crossToArrow;    // x-->

    // Kreis/Kreuz gemischt
      case 'ox': return TokenType.circleToCross;      // o--x
      case 'xo': return TokenType.crossToCircle;      // x--o

    // Default fallback
      default: return TokenType.line;
    }
  }

  Token scanIdentifier(int start, int startLine, int startColumn) {
    while (!isAtEnd() && (isAlphaNumeric(peek()) || peek() == '_' || peek() == '-')) {
      advance();
    }

    final value = source.substring(start, position);

    // DEBUG: Print context state
    print('DEBUG scanIdentifier: "$value", _inShapeContext: $_inShapeContext, _braceDepth: $_braceDepth');

    // Check für FontAwesome: fa:fa-icon
    if (value == 'fa' && !isAtEnd() && peek() == ':') {
      advance(); // consume ':'
      if (scanFontAwesome()) {
        final fullValue = source.substring(start, position);
        return Token(TokenType.fontAwesome, fullValue, startLine, startColumn, start);
      }
    }

    final type = getKeywordType(value);
    print('DEBUG getKeywordType("$value") returned: $type');
    return Token(type, value, startLine, startColumn, start);
  }

  bool scanFontAwesome() {
    // Scan fa-icon-name pattern
    if (!isAtEnd() && peek() == 'f' && peekAhead(1) == 'a' && peekAhead(2) == '-') {
      advance(); // f
      advance(); // a
      advance(); // -

      while (!isAtEnd() && (isAlphaNumeric(peek()) || peek() == '-')) {
        advance();
      }
      return true;
    }
    return false;
  }

  Token scanNumber(int start, int startLine, int startColumn) {
    while (!isAtEnd() && isDigit(peek())) {
      advance();
    }

    final value = source.substring(start, position);
    return Token(TokenType.number, value, startLine, startColumn, start);
  }

  TokenType getKeywordType(String text) {
    final lowercase = text.toLowerCase();

    // Context-aware Shape-Erkennung
    if (_inShapeContext && _shapeKeywords.containsKey(lowercase)) {
      return _shapeKeywords[lowercase]!;
    }

    // Standard Keywords (immer erkannt)
    switch (lowercase) {
    // Grundlegende Direktiven
      case 'flowchart': return TokenType.flowchart;
      case 'graph': return TokenType.graph;
      case 'subgraph': return TokenType.subgraph;
      case 'end': return TokenType.end;

    // Richtungen
      case 'td':
      case 'tb':
      case 'bt':
      case 'rl':
      case 'lr': return TokenType.direction;

    // Styling-Direktiven
      case 'classdef': return TokenType.classDef;
      case 'class': return TokenType.class_;
      case 'linkstyle': return TokenType.linkStyle;
      case 'click': return TokenType.click;
      case 'style': return TokenType.style;

    // Neue Syntax Keywords
      case 'shape': return TokenType.shape;
      case 'label': return TokenType.label;

    // Alles andere ist identifier
      default: return TokenType.identifier;
    }
  }

  // Hilfsmethoden (unverändert)
  String advance() {
    if (isAtEnd()) return '\0';
    final char = source[position];
    position++;
    column++;
    return char;
  }

  String peek([int offset = 0]) {
    final pos = position + offset;
    return pos >= source.length ? '\0' : source[pos];
  }

  String peekAhead(int offset) => peek(offset);

  bool isAtEnd() => position >= source.length;

  bool isAlpha(String char) {
    if (char == '\0') return false;
    final code = char.codeUnitAt(0);
    return (code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0)) ||
        (code >= 'A'.codeUnitAt(0) && code <= 'Z'.codeUnitAt(0));
  }

  bool isDigit(String char) {
    if (char == '\0') return false;
    final code = char.codeUnitAt(0);
    return code >= '0'.codeUnitAt(0) && code <= '9'.codeUnitAt(0);
  }

  bool isAlphaNumeric(String char) => isAlpha(char) || isDigit(char);

  void skipWhitespace() {
    while (!isAtEnd() && (peek() == ' ' || peek() == '\t' || peek() == '\r')) {
      advance();
    }
  }
}

@immutable
class ParseException implements Exception {
  const ParseException(this.message, this.line, this.column);
  final String message;
  final int line;
  final int column;

  @override
  String toString() => 'ParseException: $message at line $line, column $column';
}