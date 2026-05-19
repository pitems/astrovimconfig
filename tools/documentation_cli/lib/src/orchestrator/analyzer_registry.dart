import '../analyzers/dart/dart_analyzer.dart';
import '../analyzers/document_analyzer.dart';
import '../analyzers/typescript/typescript_analyzer.dart';

class AnalyzerRegistry {
  AnalyzerRegistry({Iterable<DocumentAnalyzer>? analyzers})
      : _analyzers = List<DocumentAnalyzer>.unmodifiable(
          analyzers ??
              <DocumentAnalyzer>[
                DartAnalyzer(),
                TypeScriptAnalyzer(),
              ],
        );

  final List<DocumentAnalyzer> _analyzers;

  DocumentAnalyzer? resolve(String fileType) {
    for (final analyzer in _analyzers) {
      if (analyzer.supports(fileType)) {
        return analyzer;
      }
    }
    return null;
  }
}
