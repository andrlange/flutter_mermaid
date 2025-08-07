

import '../base_graph.dart';
import '../mermaid_object.dart';
import 'flowchart_edge.dart';
import 'flowchart_node.dart';


class FlowchartGraph extends BaseGraph{
  final List<FlowchartNode> _nodes = [];
  final List<FlowChartEdge> _edges = [];
  final List<FlowchartGraph> _subGraphs = [];
  MermaidDirection _direction = MermaidDirection.td;


  @override
  MermaidType get type => MermaidType.flowchart;

  @override
  String toString() {
    return '$_nodes\n$_edges\n$_subGraphs\n$_direction\n';
  }
}