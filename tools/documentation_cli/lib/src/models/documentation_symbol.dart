import 'documentation_parameter.dart';

class DocumentationSymbol {
  const DocumentationSymbol({
    required this.kind,
    required this.name,
    this.signature,
    this.returnType,
    this.typeAnnotation,
    this.visibility,
    this.lineStart,
    this.lineEnd,
    this.parameters = const <DocumentationParameter>[],
    this.children = const <DocumentationSymbol>[],
    this.metadata = const <String, dynamic>{},
  });

  final String kind;
  final String name;
  final String? signature;
  final String? returnType;
  final String? typeAnnotation;
  final String? visibility;
  final int? lineStart;
  final int? lineEnd;
  final List<DocumentationParameter> parameters;
  final List<DocumentationSymbol> children;
  final Map<String, dynamic> metadata;

  DocumentationSymbol copyWith({
    String? kind,
    String? name,
    String? signature,
    String? returnType,
    String? typeAnnotation,
    String? visibility,
    int? lineStart,
    int? lineEnd,
    List<DocumentationParameter>? parameters,
    List<DocumentationSymbol>? children,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentationSymbol(
      kind: kind ?? this.kind,
      name: name ?? this.name,
      signature: signature ?? this.signature,
      returnType: returnType ?? this.returnType,
      typeAnnotation: typeAnnotation ?? this.typeAnnotation,
      visibility: visibility ?? this.visibility,
      lineStart: lineStart ?? this.lineStart,
      lineEnd: lineEnd ?? this.lineEnd,
      parameters: parameters ?? this.parameters,
      children: children ?? this.children,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'kind': kind,
      'name': name,
      if (signature != null) 'signature': signature,
      if (returnType != null) 'returnType': returnType,
      if (typeAnnotation != null) 'typeAnnotation': typeAnnotation,
      if (visibility != null) 'visibility': visibility,
      if (lineStart != null) 'lineStart': lineStart,
      if (lineEnd != null) 'lineEnd': lineEnd,
      if (parameters.isNotEmpty)
        'parameters': parameters.map((parameter) => parameter.toJson()).toList(),
      if (children.isNotEmpty)
        'children': children.map((symbol) => symbol.toJson()).toList(),
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  factory DocumentationSymbol.fromJson(Map<String, dynamic> json) {
    return DocumentationSymbol(
      kind: json['kind'] as String,
      name: json['name'] as String,
      signature: json['signature'] as String?,
      returnType: json['returnType'] as String?,
      typeAnnotation: json['typeAnnotation'] as String?,
      visibility: json['visibility'] as String?,
      lineStart: json['lineStart'] as int?,
      lineEnd: json['lineEnd'] as int?,
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((item) => DocumentationParameter.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DocumentationParameter>[],
      children: (json['children'] as List<dynamic>?)
              ?.map((item) => DocumentationSymbol.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DocumentationSymbol>[],
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }
}
