import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';

import '../../contracts/documentation_contract.dart';
import '../../models/documentation_metadata.dart';
import '../../models/documentation_request.dart';
import '../../models/documentation_result.dart';
import '../../models/documentation_template.dart';
import '../../models/documentation_symbol.dart';
import '../document_analyzer.dart';
import 'helpers/dart_ast_collector.dart';

class DartAnalyzer implements DocumentAnalyzer {
  @override
  String get language => 'dart';

  @override
  bool supports(String fileType) => fileType.toLowerCase() == 'dart';

  @override
  Future<DocumentationResult> analyze(DocumentationRequest request) async {
    // Parse the source into a Dart AST and keep diagnostics for the doc notes.
    final source = request.sourceText ?? await File(request.sourcePath).readAsString();
    final parsed = parseString(
      content: source,
      path: request.sourcePath,
      throwIfDiagnostics: false,
    );

    // Collect top-level symbols, internal references, and import metadata.
    final visitor = DartAstCollector(
      parsed.lineInfo,
      projectRoot: request.projectRoot ?? _projectRootForSource(request.sourcePath),
      sourcePath: request.sourcePath,
    );
    parsed.unit.accept(visitor);
    final layout = _detectLayout(visitor.symbols);

    final warnings = <String>[
      ...parsed.errors.map((error) => error.message),
    ];

    return DocumentationResult(
      language: language,
      sourcePath: request.sourcePath,
      docPath: request.docPath,
      projectRoot: request.projectRoot,
      template: _templateFor(
        layout: layout,
        title: 'Documentation: ${_baseNameWithoutExtension(request.sourcePath)}',
      ),
      symbols: visitor.symbols,
      dependencies: visitor.dependencies,
      references: visitor.references,
      metadata: DocumentationMetadata(
        generatedAt: DateTime.now().toUtc().toIso8601String(),
        analyzer: 'package:analyzer',
        toolVersion: DocumentationContract.toolVersion,
        sourceLineCount: parsed.lineInfo.lineCount,
        extra: <String, dynamic>{
          'sourceLength': source.length,
          'parseErrorCount': parsed.errors.length,
        },
      ),
      warnings: warnings,
    );
  }

  String _baseName(String sourcePath) {
    return sourcePath.split('/').last;
  }

  String _baseNameWithoutExtension(String sourcePath) {
    final name = _baseName(sourcePath);
    return name.replaceFirst(RegExp(r'\.[^.]+$'), '');
  }

  String _projectRootForSource(String sourcePath) {
    final normalized = sourcePath.replaceAll('\\', '/');
    final libIndex = normalized.lastIndexOf('/lib/');
    if (libIndex > 0) {
      return normalized.substring(0, libIndex);
    }
    return File(sourcePath).parent.path;
  }

  DocumentationTemplate _templateFor({
    required String layout,
    required String title,
  }) {
    switch (layout) {
      case DocumentationContract.templateLayoutController:
        return DocumentationTemplate.controllerFor(title);
      default:
        return DocumentationTemplate.moduleFor(title);
    }
  }

  String _detectLayout(List<DocumentationSymbol> symbols) {
    final classes = symbols.where((symbol) => symbol.kind == 'class').toList();
    final topLevelFunctions = symbols.where((symbol) => symbol.kind == 'function').length;
    final topLevelVariables = symbols.where((symbol) => symbol.kind == 'variable').length;

    if (classes.isEmpty) {
      return DocumentationContract.templateLayoutModule;
    }

    final totalClassMembers = classes.fold<int>(
      0,
      (sum, symbol) => sum + symbol.children.length,
    );
    final primaryClass = classes.first;
    final primaryName = primaryClass.name;
    final hasControllerName = RegExp(r'(controller|bloc|manager|state|cubit)$', caseSensitive: false)
        .hasMatch(primaryName);
    final inheritedControllerType = _classInheritanceSuggestsController(primaryClass);
    final classDominates = totalClassMembers >= 1 &&
        totalClassMembers >= (topLevelFunctions + topLevelVariables);

    if ((hasControllerName || inheritedControllerType) && classDominates) {
      return DocumentationContract.templateLayoutController;
    }

    return DocumentationContract.templateLayoutModule;
  }

  bool _classInheritanceSuggestsController(DocumentationSymbol classSymbol) {
    final superclass = (classSymbol.metadata['superclass'] as String?) ?? '';
    if (superclass.isEmpty) {
      return false;
    }

    return RegExp(r'(cubit|bloc|controller|manager|state)$', caseSensitive: false)
        .hasMatch(superclass);
  }
}
