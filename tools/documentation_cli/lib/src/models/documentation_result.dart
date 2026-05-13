import '../contracts/documentation_contract.dart';
import 'documentation_metadata.dart';
import 'documentation_symbol.dart';
import 'documentation_template.dart';

class DocumentationResult {
  const DocumentationResult({
    required this.language,
    required this.sourcePath,
    required this.docPath,
    required this.projectRoot,
    required this.template,
    required this.symbols,
    required this.dependencies,
    required this.metadata,
    this.references = const <DocumentationReference>[],
    this.warnings = const <String>[],
  });

  final String language;
  final String sourcePath;
  final String docPath;
  final String? projectRoot;
  final DocumentationTemplate template;
  final List<DocumentationSymbol> symbols;
  final List<Map<String, dynamic>> dependencies;
  final List<DocumentationReference> references;
  final DocumentationMetadata metadata;
  final List<String> warnings;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': DocumentationContract.schemaVersion,
      'language': language,
      'sourcePath': sourcePath,
      'docPath': docPath,
      if (projectRoot != null) 'projectRoot': projectRoot,
      'template': template.toJson(),
      'symbols': symbols.map((symbol) => symbol.toJson()).toList(),
      'dependencies': dependencies,
      'references': references.map((reference) => reference.toJson()).toList(),
      'metadata': metadata.toJson(),
      'warnings': warnings,
    };
  }

  factory DocumentationResult.fromJson(Map<String, dynamic> json) {
    return DocumentationResult(
      language: json['language'] as String,
      sourcePath: json['sourcePath'] as String,
      docPath: json['docPath'] as String,
      projectRoot: json['projectRoot'] as String?,
      template: DocumentationTemplate.fromJson(
        Map<String, dynamic>.from(json['template'] as Map),
      ),
      symbols: (json['symbols'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (item) => DocumentationSymbol.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      dependencies: (json['dependencies'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      references: (json['references'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (item) => DocumentationReference.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      metadata: DocumentationMetadata.fromJson(
        Map<String, dynamic>.from(json['metadata'] as Map),
      ),
      warnings: (json['warnings'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item as String)
          .toList(),
    );
  }
}

class DocumentationReference {
  const DocumentationReference({
    required this.name,
    required this.sourcePath,
    required this.docPath,
    required this.exists,
    required this.kind,
  });

  final String name;
  final String sourcePath;
  final String docPath;
  final bool exists;
  final String kind;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'sourcePath': sourcePath,
      'docPath': docPath,
      'exists': exists,
      'kind': kind,
    };
  }

  factory DocumentationReference.fromJson(Map<String, dynamic> json) {
    return DocumentationReference(
      name: json['name'] as String,
      sourcePath: json['sourcePath'] as String,
      docPath: json['docPath'] as String,
      exists: json['exists'] as bool? ?? false,
      kind: json['kind'] as String,
    );
  }
}
