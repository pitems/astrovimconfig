class DocumentationParameter {
  const DocumentationParameter({
    required this.name,
    this.type,
    this.description,
    this.defaultValue,
    this.isRequired = false,
    this.isNamed = false,
  });

  final String name;
  final String? type;
  final String? description;
  final String? defaultValue;
  final bool isRequired;
  final bool isNamed;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (defaultValue != null) 'defaultValue': defaultValue,
      'isRequired': isRequired,
      'isNamed': isNamed,
    };
  }

  factory DocumentationParameter.fromJson(Map<String, dynamic> json) {
    return DocumentationParameter(
      name: json['name'] as String,
      type: json['type'] as String?,
      description: json['description'] as String?,
      defaultValue: json['defaultValue'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      isNamed: json['isNamed'] as bool? ?? false,
    );
  }
}
