import 'package:flutter/material.dart';

// =============================================================================
// NODE STYLE CONFIGURATION
// =============================================================================

enum BorderType {
  thin,
  normal,
  thick,
  thinDashed,
  dashed,
  thickDashed,
}

class NodeStyle {
  const NodeStyle({
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.textColor = Colors.black,
    this.borderType = BorderType.normal,
    this.hasLink = false,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final BorderType borderType;
  final bool hasLink;

  double get borderWidth {
    switch (borderType) {
      case BorderType.thin:
      case BorderType.thinDashed:
        return 1.0;
      case BorderType.normal:
      case BorderType.dashed:
        return 2.0;
      case BorderType.thick:
      case BorderType.thickDashed:
        return 3.0;
    }
  }

  bool get isDashed {
    return [
      BorderType.thinDashed,
      BorderType.dashed,
      BorderType.thickDashed,
    ].contains(borderType);
  }

  NodeStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
    BorderType? borderType,
    bool? hasLink,
  }) {
    return NodeStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      borderType: borderType ?? this.borderType,
      hasLink: hasLink ?? this.hasLink,
    );
  }
}