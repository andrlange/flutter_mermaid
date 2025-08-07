import 'base_graph.dart';

enum MermaidType {
  flowchart('flowchart'),
  sequenceDiagram('sequenceDiagram'),
  classDiagram('classDiagram'),
  stateDiagram('stateDiagram-v2'),
  entityRelationshipDiagram('erDiagram'),
  userJourney('journey'),
  gantt('gantt'),
  pieChart('pie'),
  quadrantChart('quadrantChart'),
  requirementDiagram('requirementDiagram'),
  gitGraph('gitGraph'),
  c4Diagram('C4Context'),
  mindMaps('mindmap'),
  timeline('timeline'),
  zenUml('zenuml'),
  sankey('sankey-beta'),
  xyChart('xychart-beta'),
  blockDiagram('block-beta'),
  packet('packet'),
  kanban('kanban'),
  architecture('architecture-beta'),
  radar('radar-beta'),
  treemap('treemap-beta'),
  unknown('unknown');

  const MermaidType(this.name);

  final String name;
}

enum MermaidDirection {
  td('TD'),
  lr('LR'),
  tb('TB'),
  rl('RL');

  const MermaidDirection(this.direction);

  final String direction;
}

class MermaidConfig {
  const MermaidConfig(
    this.title,
    this.theme,
    this.displayMode,
    this.themeVariables,
  );

  final String title;
  final String theme;
  final String displayMode;
  final Map<String, dynamic> themeVariables;

  @override
  String toString() {
    return 'MermaidConfig:\n    title: $title\n    theme: $theme\n'
        '    displayMode: $displayMode\n    themeVariables: $themeVariables\n';
  }
}

class MermaidObject {
  const MermaidObject(
    this.mermaidType,
    this.mermaidDirection,
    this.mermaidText,
    this.config,
    this.syntax,
      this.graph,
  );

  final MermaidType mermaidType;
  final MermaidDirection mermaidDirection;
  final String mermaidText;
  final MermaidConfig config;
  final List<String> syntax;

  final BaseGraph graph;

  @override
  String toString() {
    return 'MermaidObject:\n  mermaidType: $mermaidType\n  mermaidDirection: '
        '$mermaidDirection\n  $config\n  syntax: $syntax\n';
  }
}
