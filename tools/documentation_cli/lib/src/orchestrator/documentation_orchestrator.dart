import '../models/documentation_request.dart';
import '../models/documentation_result.dart';
import 'analyzer_registry.dart';

class DocumentationOrchestrator {
  DocumentationOrchestrator({AnalyzerRegistry? registry})
      : registry = registry ?? AnalyzerRegistry();

  final AnalyzerRegistry registry;

  Future<DocumentationResult> analyze(DocumentationRequest request) async {
    final analyzer = registry.resolve(request.fileType);
    if (analyzer == null) {
      throw UnsupportedError(
        'No analyzer registered for filetype: ${request.fileType}',
      );
    }

    return analyzer.analyze(request);
  }
}

