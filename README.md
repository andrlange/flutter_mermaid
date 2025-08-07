# Flutter Mermaid 🧜‍♀️

A comprehensive Flutter/Dart implementation of Mermaid diagrams, bringing the power of Mermaid's diagram syntax to Flutter applications.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> ⚠️ **Early Development Phase**: This project is currently in active development. Features and APIs may change as we work towards a stable release.

## 🎯 Project Vision

Flutter Mermaid aims to provide a complete, native Flutter implementation of Mermaid diagrams, enabling developers to create beautiful, interactive diagrams directly within their Flutter applications without requiring external dependencies or web views.

## 🚀 Current Features

### ✅ Flowchart Support

Our first implementation focuses on **Flowchart diagrams** with comprehensive support for:

#### Node Shapes
- **Basic Shapes**: Rectangle, Circle, Diamond, Stadium, Hexagon
- **Extended Shapes**: Cylinder, Trapezoid, Parallelogram, Double Circle
- **Advanced Shapes**: Document, Database, Process variants, and many more
- **New Syntax**: `@{shape: circle, label: "My Node"}` format support

#### Connection Types
- **Standard Connections**: Arrow (`-->`), Line (`---`), Dotted (`-.->`)
- **Styled Connections**: Thick (`==>`), Invisible (`~~~`)
- **Bidirectional**: `<-->`, Circle endings (`o--o`), Cross endings (`x--x`)
- **Mixed Connections**: `<--o`, `x-->`, `o--x` and more

#### Advanced Features
- **Subgraphs**: Nested diagram sections with titles
- **Styling**: CSS-like styling with `style` and `classDef`
- **Click Events**: Interactive callbacks and links
- **FontAwesome**: Icon support within nodes
- **Unicode**: Full emoji and international character support

#### Syntax Support
- **Classic Syntax**: `A[Rectangle] --> B{Diamond}`
- **New Syntax**: `A@{shape: rect, label: "Process"} --> B`
- **Mixed Usage**: Seamless combination of both syntaxes
- **Labels**: Connection labels with `-->|Label|` syntax

## 🏗️ Architecture

The project follows a clean, modular architecture:

```
📁 Core Parser Components
├── 🔤 MermaidLexer      - Tokenizes Mermaid syntax
├── 🌳 AST Nodes         - Abstract Syntax Tree representation  
├── 🔍 MermaidParser     - Converts tokens to AST
└── 🎭 Interpreter       - High-level parsing API

📁 Rendering Engine (Planned)
├── 🎨 Widget Renderer   - Flutter widget generation
├── 📐 Layout Engine     - Automatic diagram layout
└── 🎯 Interaction Layer - Touch and click handling
```

## 📖 Usage Examples

### Basic Flowchart

```dart
final interpreter = MermaidFlowchartInterpreter();
final document = interpreter.parse('''
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[Skip]
    C --> E[End]
    D --> E
''');
```

### Advanced Features

```dart
final complexFlowchart = '''
flowchart LR
    Start@{shape: sm-circ, label: "🚀 Begin"} --> Process[Handle Data]
    Process --> Decision@{shape: diam, label: "Valid?"}
    
    Decision -->|Yes| Success@{shape: stadium, label: "✅ Complete"}
    Decision -->|No| Error@{shape: hex, label: "❌ Failed"}
    
    subgraph ErrorHandling [Error Processing]
        Error --> Log[Log Error]
        Log --> Notify[Notify Admin]
    end
    
    classDef success fill:#d4edda,stroke:#155724
    class Success success
    
    click Success callback "handleSuccess"
    click Error "https://docs.example.com/errors"
''';
```

### Performance Metrics

```dart
final interpreter = MermaidFlowchartInterpreter();
final result = interpreter.parseWithDetails(diagramCode);

print('Parse Time: ${result.parsingTimeMs}ms');
print('Token Count: ${result.tokenCount}');
print('Statements: ${result.document?.statements.length}');
print('Warnings: ${result.warnings}');
```

## 🧪 Testing

The project includes comprehensive tests:

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/lexer_test.dart
flutter test test/parser_test.dart  
flutter test test/interpreter_test.dart
```

**Test Coverage:**
- ✅ Lexer: 100% token types, edge cases, error handling
- ✅ Parser: All syntax combinations, complex diagrams
- ✅ Interpreter: Integration tests, performance benchmarks

## 🛣️ Roadmap

### Phase 1: Core Flowchart (Current)
- [x] Complete lexer with all token types
- [x] Full parser implementation
- [x] Comprehensive test suite
- [ ] Widget rendering engine
- [ ] Basic layout algorithms

### Phase 2: Enhanced Flowcharts
- [ ] Advanced styling options
- [ ] Animation support
- [ ] Interactive editing
- [ ] Export capabilities (SVG, PNG)

### Phase 3: Additional Diagram Types
- [ ] Sequence Diagrams
- [ ] Class Diagrams
- [ ] State Diagrams
- [ ] Gantt Charts
- [ ] Pie Charts

### Phase 4: Advanced Features
- [ ] Real-time collaboration
- [ ] Custom themes
- [ ] Plugin architecture
- [ ] Web deployment support

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute
- 🐛 **Bug Reports**: Found an issue? Please create a detailed issue report
- 💡 **Feature Requests**: Have ideas? We'd love to hear them
- 🔧 **Code Contributions**: Submit pull requests for bug fixes or new features
- 📖 **Documentation**: Help improve our docs and examples
- 🧪 **Testing**: Add test cases, find edge cases

### Getting Started
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes with tests
4. Ensure all tests pass (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup
```bash
git clone https://github.com/yourusername/flutter_mermaid.git
cd flutter_mermaid
flutter pub get
flutter test  # Ensure everything works
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ☕ Support the Project

If you find this project helpful, consider supporting its development:

[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/andrlange)

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/andrlange)

[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/andrlange)

Your support helps maintain and improve this project! 🙏

## 🔗 Related Projects

- [Mermaid.js](https://mermaid.js.org/) - The original Mermaid project
- [Flutter](https://flutter.dev) - Google's UI toolkit
- [Dart](https://dart.dev) - The programming language optimized for mobile, desktop, server, and web apps

## 📞 Contact

- **Project Maintainer**: Andreas Lange
- **Email**: andr.lange@web.de
- **Issues**: Please use GitHub Issues for bug reports and feature requests

---

**Made with ❤️ for the Flutter community**

> ⭐ **Star this repo** if you find it useful! It helps others discover the project.