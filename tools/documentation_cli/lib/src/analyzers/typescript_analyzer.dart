import 'dart:io';

import '../contracts/documentation_contract.dart';
import '../models/documentation_metadata.dart';
import '../models/documentation_request.dart';
import '../models/documentation_result.dart';
import '../models/documentation_symbol.dart';
import '../models/documentation_template.dart';
import 'document_analyzer.dart';

class TypeScriptAnalyzer implements DocumentAnalyzer {
  @override
  String get language => 'typescript';

  @override
  bool supports(String fileType) {
    final normalized = fileType.toLowerCase();
    return normalized == 'typescript' || normalized == 'ts' || normalized == 'tsx';
  }

  @override
  Future<DocumentationResult> analyze(DocumentationRequest request) async {
    final source = request.sourceText ?? await File(request.sourcePath).readAsString();
    final lineCount = '\n'.allMatches(source).length + 1;

    return DocumentationResult(
      language: language,
      sourcePath: request.sourcePath,
      docPath: request.docPath,
      projectRoot: request.projectRoot,
      template: DocumentationTemplate.defaultFor(_buildTitle(request)),
      symbols: const <DocumentationSymbol>[],
      dependencies: const <Map<String, dynamic>>[],
      metadata: DocumentationMetadata(
        generatedAt: DateTime.now().toUtc().toIso8601String(),
        analyzer: 'typescript-analyzer-stub',
        toolVersion: DocumentationContract.toolVersion,
        sourceLineCount: lineCount,
        extra: <String, dynamic>{
          'note': 'Replace this stub with the TypeScript compiler API or ts-morph backend.',
          'sourceLength': source.length,
        },
      ),
      warnings: const <String>[
        'TypeScript analyzer backend is scaffolded but not wired to a real AST parser yet.',
      ],
    );
  }

  String _buildTitle(DocumentationRequest request) {
    return 'Documentation: ${request.docPath}';
  }
}
