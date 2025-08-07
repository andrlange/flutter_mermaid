import '../models/base_graph.dart';
import '../models/flowchart/flowchart_graph.dart';
import '../models/mermaid_object.dart';
import 'flowchart/flowchart_interpreter.dart';
export 'package:flutter_mermaid2/src/core/models/mermaid_object.dart';

class MermaidParser {
  static MermaidObject parse(String mermaidText) {
    var direction = MermaidDirection.td; // default direction is top-down (TD)
    var syntax = mermaidText;
    var type = MermaidType.unknown;
    var title = '';
    var theme = '';
    var displayMode = '';
    var themeVariables = <String, String>{};

    final lines = _lines(mermaidText);

    var configPreamble = false;
    var configStartLine = -1;
    var typeLine = -1;
    var themeVariablesPreamble = false;
    final syntaxLines = <String>[];

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('---') && configStartLine < 0) {
        configPreamble = true;
        configStartLine = i;
      }

      //print('i: $i, lines[i]: ${lines[i]}');
      if (configPreamble) {
        if (themeVariablesPreamble) {
          final key = _extractKey(lines[i]);
          final value = _extractValue(lines[i]);
          themeVariables.addAll({key: value});
        }

        if (lines[i].toLowerCase().startsWith('title:')) {
          title = _extractValue(lines[i]);
        } else if (lines[i].toLowerCase().startsWith('displaymode:')) {
          displayMode = _extractValue(lines[i]);
        } else if (lines[i].toLowerCase().startsWith('config:')) {
          configStartLine = i;
        } else if (configStartLine != i && lines[i].startsWith('---')) {
          configPreamble = false;
          themeVariablesPreamble = false;
        } else if (lines[i].toLowerCase().startsWith('theme:')) {
          theme = _extractValue(lines[i]);
        } else if (lines[i].toLowerCase().startsWith('themevariables:')) {
          themeVariablesPreamble = true;
        }
      } else {
        // try to check for type
        if (typeLine < 0) {
          for (var mermaidTtype in MermaidType.values) {
            if (lines[i].toLowerCase().startsWith(
              mermaidTtype.name.toLowerCase(),
            )) {
              typeLine = i;
              type = mermaidTtype;
              direction = _extractDirection(lines[i]);
              break;
            }
          }
        } else {
          // syntax parsing
          if(typeLine != i) {
            syntaxLines.add(lines[i]);
          }
        }
      }
    }

    final mermaidConfig = MermaidConfig(
      title,
      theme,
      displayMode,
      themeVariables,
    );
    BaseGraph graph = ErrorGraph();
    if(type != MermaidType.unknown) {
       graph = _parseGraph(syntax,type,direction);
    }


    return MermaidObject(
      type,
      direction,
      syntax,
      mermaidConfig,
      syntaxLines,
      graph,
    );
  }

  static List<String> _lines(String mermaidText) {
    return mermaidText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('%%'))
        .toList();
  }

  static String _extractValue(String keyValue) {
    var parts = keyValue.split(':');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  static String _extractKey(String keyValue) {
    var parts = keyValue.split(':');
    return parts.length > 1 ? parts[0].trim() : '';
  }

  static MermaidDirection _extractDirection(String line) {
    var parts = line.split(' ');
    if (parts.length > 1) {
      final direction = parts[1].toLowerCase();
      switch (direction) {
        case 'td':
          return MermaidDirection.td;
        case 'lr':
          return MermaidDirection.lr;
        case 'tb':
          return MermaidDirection.tb;
        case 'rl':
          return MermaidDirection.rl;
      }
    }
    return MermaidDirection.td;
  }


  static BaseGraph _parseGraph(String syntax, MermaidType type,
      MermaidDirection direction) {
    switch (type) {
      case MermaidType.flowchart:
        var flowchartInterpreter = MermaidFlowchartInterpreter();
        flowchartInterpreter.parse(syntax);
        return FlowchartGraph();
      // Add more cases for other mermaid types
      default:
        return FlowchartGraph();
    }
    // ToDo: Implement parsing for graph
  }
}
