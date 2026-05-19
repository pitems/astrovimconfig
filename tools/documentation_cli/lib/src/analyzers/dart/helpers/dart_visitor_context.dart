import 'package:analyzer/source/line_info.dart';

import '../../../models/documentation_result.dart';
import '../../../models/documentation_symbol.dart';
import 'dart_dependency_resolver.dart';
import 'dart_parameter_parser.dart';
import 'dart_signature_builder.dart';

class DartVisitorContext {
  DartVisitorContext({
    required this.lineInfo,
    required this.projectRoot,
    required this.sourcePath,
  })  : dependencyResolver = DartDependencyResolver(
          projectRoot: projectRoot,
          sourcePath: sourcePath,
        ),
        parameterParser = DartParameterParser(),
        signatureBuilder = DartSignatureBuilder();

  final LineInfo lineInfo;
  final String projectRoot;
  final String sourcePath;
  final DartDependencyResolver dependencyResolver;
  final DartParameterParser parameterParser;
  final DartSignatureBuilder signatureBuilder;

  final List<DocumentationSymbol> symbols = <DocumentationSymbol>[];
  final List<Map<String, dynamic>> dependencies = <Map<String, dynamic>>[];
  final List<DocumentationReference> references = <DocumentationReference>[];

  final List<_ClassFrame> _classStack = <_ClassFrame>[];

  void beginClass(DocumentationSymbol symbol) {
    _classStack.add(_ClassFrame(symbol: symbol));
  }

  DocumentationSymbol endClass() {
    final frame = _classStack.removeLast();
    return frame.symbol.copyWith(
      children: List<DocumentationSymbol>.unmodifiable(frame.children),
    );
  }

  void addSymbol(DocumentationSymbol symbol) {
    if (_classStack.isNotEmpty) {
      _classStack.last.children.add(symbol);
      return;
    }

    symbols.add(symbol);
  }

  void addDependency({
    required String kind,
    required String path,
    required String name,
    required int lineStart,
    required int lineEnd,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    dependencies.add(
      <String, dynamic>{
        'kind': kind,
        'path': path,
        'name': name,
        'lineStart': lineNumber(lineStart),
        'lineEnd': lineNumber(lineEnd),
        if (metadata.isNotEmpty) 'metadata': metadata,
      },
    );
  }

  void addReference(DocumentationReference reference) {
    references.add(reference);
  }

  int lineNumber(int offset) => lineInfo.getLocation(offset).lineNumber;

  String visibility(String name) => name.startsWith('_') ? 'private' : 'public';
}

class _ClassFrame {
  _ClassFrame({required this.symbol});

  final DocumentationSymbol symbol;
  final List<DocumentationSymbol> children = <DocumentationSymbol>[];
}
