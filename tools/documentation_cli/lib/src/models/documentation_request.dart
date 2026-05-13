class DocumentationRequest {
  const DocumentationRequest({
    required this.sourcePath,
    required this.docPath,
    required this.fileType,
    this.projectRoot,
    this.sourceText,
    this.templateName,
  });

  final String sourcePath;
  final String docPath;
  final String fileType;
  final String? projectRoot;
  final String? sourceText;
  final String? templateName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sourcePath': sourcePath,
      'docPath': docPath,
      'fileType': fileType,
      if (projectRoot != null) 'projectRoot': projectRoot,
      if (sourceText != null) 'sourceText': sourceText,
      if (templateName != null) 'templateName': templateName,
    };
  }

  factory DocumentationRequest.fromJson(Map<String, dynamic> json) {
    return DocumentationRequest(
      sourcePath: json['sourcePath'] as String,
      docPath: json['docPath'] as String,
      fileType: json['fileType'] as String,
      projectRoot: json['projectRoot'] as String?,
      sourceText: json['sourceText'] as String?,
      templateName: json['templateName'] as String?,
    );
  }
}

