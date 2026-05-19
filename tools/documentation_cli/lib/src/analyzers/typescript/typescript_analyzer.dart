import 'dart:convert';
import 'dart:io';

import '../../contracts/documentation_contract.dart';
import '../../models/documentation_metadata.dart';
import '../../models/documentation_request.dart';
import '../../models/documentation_result.dart';
import '../../models/documentation_symbol.dart';
import '../../models/documentation_template.dart';
import '../document_analyzer.dart';
import '../../templates/typescript/typescript_template.dart';

class TypeScriptAnalyzer implements DocumentAnalyzer {
  @override
  String get language => 'typescript';

  @override
  bool supports(String fileType) {
    final normalized = fileType.toLowerCase();
    return normalized == 'typescript' ||
        normalized == 'ts' ||
        normalized == 'tsx' ||
        normalized == 'javascript' ||
        normalized == 'js' ||
        normalized == 'jsx';
  }

  @override
  Future<DocumentationResult> analyze(DocumentationRequest request) async {
    final backendResult = await _runBackend(request);
    if (backendResult != null) {
      return backendResult;
    }

    final source = request.sourceText ?? await File(request.sourcePath).readAsString();
    return _fallbackResult(request, source);
  }

  Future<DocumentationResult?> _runBackend(DocumentationRequest request) async {
    final backendScript = File('typescript_backend/src/index.js');
    if (!backendScript.existsSync()) {
      return null;
    }

    try {
      final process = await Process.start(
        'node',
        [backendScript.path],
        workingDirectory: Directory.current.path,
        runInShell: false,
      );

      process.stdin.write(jsonEncode(request.toJson()));
      await process.stdin.close();

      final stdoutText = await process.stdout.transform(utf8.decoder).join();
      final stderrText = await process.stderr.transform(utf8.decoder).join();
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        stderr.writeln(stderrText.isNotEmpty ? stderrText : 'TypeScript backend exited with code $exitCode');
        return null;
      }

      final decoded = jsonDecode(stdoutText);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return DocumentationResult.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  DocumentationResult _fallbackResult(DocumentationRequest request, String source) {
    final layout = _layoutFromTemplateName(request.templateName);

    return DocumentationResult(
      language: language,
      sourcePath: request.sourcePath,
      docPath: request.docPath,
      projectRoot: request.projectRoot,
      template: _templateFor(
        layout: layout,
        title: _buildTitle(request),
      ),
      symbols: const <DocumentationSymbol>[],
      dependencies: const <Map<String, dynamic>>[],
      metadata: DocumentationMetadata(
        generatedAt: DateTime.now().toUtc().toIso8601String(),
        analyzer: 'typescript-scaffold',
        toolVersion: DocumentationContract.toolVersion,
        sourceLineCount: '\n'.allMatches(source).length + 1,
        extra: <String, dynamic>{
          'note': 'TypeScript backend scaffold is ready for a real parser.',
          'sourceLength': source.length,
        },
      ),
      warnings: const <String>[],
    );
  }

  DocumentationTemplate _templateFor({
    required String layout,
    required String title,
  }) {
    switch (layout) {
      case DocumentationContract.templateLayoutController:
        return DocumentationTemplate(
          name: TypeScriptDocumentationTemplate.controllerFor(title).name,
          title: title,
          layout: DocumentationContract.templateLayoutController,
          sectionOrder: DocumentationContract.defaultSectionOrder,
          headings: TypeScriptDocumentationTemplate.controllerFor(title).headings,
        );
      default:
        return DocumentationTemplate(
          name: TypeScriptDocumentationTemplate.moduleFor(title).name,
          title: title,
          layout: DocumentationContract.templateLayoutModule,
          sectionOrder: DocumentationContract.defaultSectionOrder,
          headings: TypeScriptDocumentationTemplate.moduleFor(title).headings,
        );
    }
  }

  String _layoutFromTemplateName(String? templateName) {
    final normalized = (templateName ?? '').toLowerCase();
    if (normalized.contains('controller')) {
      return DocumentationContract.templateLayoutController;
    }
    return DocumentationContract.templateLayoutModule;
  }

  String _buildTitle(DocumentationRequest request) {
    final name = request.sourcePath.split('/').last.replaceFirst(RegExp(r'\.[^.]+$'), '');
    return 'Documentation: $name';
  }

}
