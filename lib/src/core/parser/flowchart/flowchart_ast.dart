// =============================================================================
// ABSTRACT SYNTAX TREE (AST) NODES - EXTENDED
// =============================================================================

import 'package:flutter/foundation.dart';

abstract class ASTNode {
  void accept(ASTVisitor visitor);
}

class FlowchartDocument extends ASTNode {
  FlowchartDocument(this.statements, {this.direction});
  final String? direction;
  final List<Statement> statements;

  @override
  void accept(ASTVisitor visitor) => visitor.visitFlowchartDocument(this);
}

abstract class Statement extends ASTNode {}

class NodeStatement extends Statement {
  NodeStatement(this.id, this.shape, {
    this.text,
    this.shapeParams,
    this.fontAwesome,  // NEU: FontAwesome-Unterstützung
  });
  final String id;
  final NodeShape shape;
  final String? text;
  final Map<String, dynamic>? shapeParams;
  final FontAwesome? fontAwesome;  // NEU

  @override
  void accept(ASTVisitor visitor) => visitor.visitNodeStatement(this);

  @override
  String toString() => 'NodeStatement(id: $id, shape: $shape, text: $text)';
}

class ConnectionStatement extends Statement {
  ConnectionStatement(this.fromId, this.toId, this.type, {
    this.label,
    this.edgeId,
    this.length = 1
  });
  final String fromId;
  final String toId;
  final ConnectionType type;
  final String? label;
  final String? edgeId;
  final int length;

  @override
  void accept(ASTVisitor visitor) => visitor.visitConnectionStatement(this);

  @override
  String toString() => 'ConnectionStatement(from: $fromId, to: $toId, type: $type)';
}

class ChainedConnectionStatement extends Statement {
  ChainedConnectionStatement(this.nodeIds, this.type, {this.labels});
  final List<String> nodeIds;
  final ConnectionType type;
  final Map<int, String>? labels;

  @override
  void accept(ASTVisitor visitor) => visitor.visitChainedConnectionStatement(this);
}

class SubgraphStatement extends Statement {
  SubgraphStatement(this.statements, {this.id, this.title, this.direction});
  final String? id;
  final String? title;
  final List<Statement> statements;
  final String? direction;

  @override
  void accept(ASTVisitor visitor) => visitor.visitSubgraphStatement(this);

  @override
  String toString() => 'SubgraphStatement(id: $id, title: $title, statements: ${statements.length})';
}

class StyleStatement extends Statement {
  StyleStatement(this.target, this.properties);
  final String target;
  final Map<String, String> properties;

  @override
  void accept(ASTVisitor visitor) => visitor.visitStyleStatement(this);
}

class ClassDefStatement extends Statement {
  ClassDefStatement(this.className, this.properties);
  final String className;
  final Map<String, String> properties;

  @override
  void accept(ASTVisitor visitor) => visitor.visitClassDefStatement(this);
}

class ClassStatement extends Statement {
  ClassStatement(this.nodeIds, this.className);
  final List<String> nodeIds;
  final String className;

  @override
  void accept(ASTVisitor visitor) => visitor.visitClassStatement(this);
}

class ClickStatement extends Statement {
  ClickStatement(this.nodeId, this.action, {this.tooltip});
  final String nodeId;
  final ClickAction action;
  final String? tooltip;

  @override
  void accept(ASTVisitor visitor) => visitor.visitClickStatement(this);
}

class LinkStyleStatement extends Statement {
  LinkStyleStatement(this.linkIndices, this.properties);
  final List<int> linkIndices;
  final Map<String, String> properties;

  @override
  void accept(ASTVisitor visitor) => visitor.visitLinkStyleStatement(this);
}

// =============================================================================
// NEU: FONTAWESOME KLASSE
// =============================================================================

@immutable
class FontAwesome {
  const FontAwesome(this.iconName, {this.prefix = 'fa'});
  final String prefix;    // 'fa'
  final String iconName;  // 'fa-user', 'fa-database', etc.

  @override
  String toString() => '$prefix:$iconName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FontAwesome &&
        other.prefix == prefix &&
        other.iconName == iconName;
  }

  @override
  int get hashCode => Object.hash(prefix, iconName);
}

// =============================================================================
// VISITOR PATTERN
// =============================================================================

abstract class ASTVisitor {
  void visitFlowchartDocument(FlowchartDocument node);
  void visitNodeStatement(NodeStatement node);
  void visitConnectionStatement(ConnectionStatement node);
  void visitChainedConnectionStatement(ChainedConnectionStatement node);
  void visitSubgraphStatement(SubgraphStatement node);
  void visitStyleStatement(StyleStatement node);
  void visitClassDefStatement(ClassDefStatement node);
  void visitClassStatement(ClassStatement node);
  void visitClickStatement(ClickStatement node);
  void visitLinkStyleStatement(LinkStyleStatement node);
}

// =============================================================================
// ERWEITERTE ENUMS
// =============================================================================

enum NodeShape {
  // Bestehende Shapes (unverändert)
  rectangle, roundedRect, stadium, subroutine, cylinder, circle, asymmetric,
  rhombus, hexagon, parallelogram, parallelogramAlt, trapezoid, trapezoidAlt,
  doubleCircle, customShape,

  // NEU: Shapes aus der Referenz-Tabelle hinzugefügt
  notchRect, hourglass, bolt, brace, braceR, braces, leanR, leanL, cyl,
  diam, delay, hCyl, linCyl, curvTrap, divRect, doc, rounded, tri, fork,
  winPane, fCirc, linDoc, linRect, notchPent, flipTri, slRect, trapT,
  docs, stRect, odd, flag, hex, trapB, rect, smCirc, dblCirc, frCirc,
  bowRect, frRect, crossCirc, tagDoc, tagRect, textBlock,
}

enum ConnectionType {
  // Bestehende Verbindungen (unverändert)
  arrow, line, dottedArrow, dottedLine, thickArrow, thickLine,
  invisibleLink, circleArrow, crossArrow, bidirectional,

  // NEU: Erweiterte bidirektionale Verbindungen hinzugefügt
  bidirectionalCircle, bidirectionalCross, arrowToCircle, arrowToCross,
  circleToArrow, crossToArrow, circleToCross, crossToCircle,
}

// =============================================================================
// CLICK ACTIONS (unverändert)
// =============================================================================

@immutable
abstract class ClickAction {}

@immutable
class CallbackAction extends ClickAction {
  CallbackAction(this.functionName, {this.isCall = false});
  final String functionName;
  final bool isCall;
}

@immutable
class LinkAction extends ClickAction {
  LinkAction(this.url, {this.target});
  final String url;
  final String? target;
}

@immutable
class HrefAction extends ClickAction {
  HrefAction(this.url, {this.target});
  final String url;
  final String? target;
}