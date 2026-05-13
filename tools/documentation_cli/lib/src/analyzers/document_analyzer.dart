import '../models/documentation_request.dart';
import '../models/documentation_result.dart';

abstract class DocumentAnalyzer {
  String get language;

  bool supports(String fileType);

  Future<DocumentationResult> analyze(DocumentationRequest request);
}

