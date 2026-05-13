class DocumentationMetadata {
  const DocumentationMetadata({
    required this.generatedAt,
    required this.analyzer,
    required this.sourceLineCount,
    this.toolVersion,
    this.sourceHash,
    this.extra = const <String, dynamic>{},
  });

  final String generatedAt;
  final String analyzer;
  final String? toolVersion;
  final String? sourceHash;
  final int sourceLineCount;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'generatedAt': generatedAt,
      'analyzer': analyzer,
      'sourceLineCount': sourceLineCount,
      if (toolVersion != null) 'toolVersion': toolVersion,
      if (sourceHash != null) 'sourceHash': sourceHash,
      if (extra.isNotEmpty) ...extra,
    };
  }

  factory DocumentationMetadata.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{}..addAll(json);
    extra.remove('generatedAt');
    extra.remove('analyzer');
    extra.remove('toolVersion');
    extra.remove('sourceHash');
    extra.remove('sourceLineCount');

    return DocumentationMetadata(
      generatedAt: json['generatedAt'] as String,
      analyzer: json['analyzer'] as String,
      toolVersion: json['toolVersion'] as String?,
      sourceHash: json['sourceHash'] as String?,
      sourceLineCount: json['sourceLineCount'] as int,
      extra: extra,
    );
  }
}

