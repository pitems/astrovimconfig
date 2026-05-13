import '../contracts/documentation_contract.dart';

class DocumentationTemplate {
  const DocumentationTemplate({
    required this.name,
    required this.title,
    required this.layout,
    required this.sectionOrder,
    this.headings = const <String, String>{},
  });

  final String name;
  final String title;
  final String layout;
  final List<String> sectionOrder;
  final Map<String, String> headings;

  factory DocumentationTemplate.defaultFor(String title) {
    return DocumentationTemplate.moduleFor(title);
  }

  factory DocumentationTemplate.moduleFor(String title) {
    return DocumentationTemplate(
      name: DocumentationContract.defaultTemplateName,
      title: title,
      layout: DocumentationContract.templateLayoutModule,
      sectionOrder: DocumentationContract.defaultSectionOrder,
      headings: const <String, String>{
        'overview': 'Overview',
        'variables': 'Variables',
        'classes': 'Classes',
        'functions': 'Functions',
        'deprecated': 'Deprecated',
        'dependencies': 'Dependencies',
        'notes': 'Notes',
      },
    );
  }

  factory DocumentationTemplate.controllerFor(String title) {
    return DocumentationTemplate(
      name: 'controller_standard',
      title: title,
      layout: DocumentationContract.templateLayoutController,
      sectionOrder: DocumentationContract.defaultSectionOrder,
      headings: const <String, String>{
        'overview': 'Overview',
        'variables': 'Variables',
        'classes': 'Classes',
        'functions': 'Functions',
        'deprecated': 'Deprecated',
        'dependencies': 'Dependencies',
        'notes': 'Notes',
      },
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'title': title,
      'layout': layout,
      'sectionOrder': sectionOrder,
      if (headings.isNotEmpty) 'headings': headings,
    };
  }

  factory DocumentationTemplate.fromJson(Map<String, dynamic> json) {
    return DocumentationTemplate(
      name: json['name'] as String,
      title: json['title'] as String,
      layout: json['layout'] as String? ?? DocumentationContract.templateLayoutModule,
      sectionOrder: (json['sectionOrder'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      headings: Map<String, String>.from(
        json['headings'] as Map? ?? const <String, String>{},
      ),
    );
  }
}
