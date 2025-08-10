import 'package:flutter/material.dart';

import 'demo/demo_page.dart';

// =============================================================================
// APP ENTRY POINT
// =============================================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mermaid Node Widgets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const NodeWidgetDemo(),
    );
  }
}