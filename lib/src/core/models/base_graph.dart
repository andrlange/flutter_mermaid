

import 'mermaid_object.dart';

abstract class BaseGraph {
  MermaidType get type;
}

class ErrorGraph extends BaseGraph {
  @override
  MermaidType get type => MermaidType.unknown;
}