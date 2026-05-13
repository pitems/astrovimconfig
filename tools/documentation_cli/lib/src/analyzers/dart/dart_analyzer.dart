import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';

import '../../contracts/documentation_contract.dart';
import '../../models/documentation_metadata.dart';
import '../../models/documentation_request.dart';
import '../../models/documentation_result.dart';
import '../../models/documentation_template.dart';
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

    final warnings = <String>[
      ...parsed.errors.map((error) => error.message),
    ];

    return DocumentationResult(
      language: language,
      sourcePath: request.sourcePath,
      docPath: request.docPath,
      projectRoot: request.projectRoot,
      template: DocumentationTemplate.defaultFor(
        'Documentation: ${_baseNameWithoutExtension(request.sourcePath)}',
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
}
