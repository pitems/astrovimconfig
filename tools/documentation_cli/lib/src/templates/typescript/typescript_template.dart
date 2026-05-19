import '../../contracts/documentation_contract.dart';

class TypeScriptDocumentationTemplate {
  static const List<String> defaultSectionOrder = <String>[
    'overview',
    'variables',
    'interfaces',
    'enums',
    'type-aliases',
    'classes',
    'functions',
    'deprecated',
    'dependencies',
    'notes',
  ];

  static const Map<String, String> defaultHeadings = <String, String>{
    'overview': 'Overview',
    'variables': 'Variables',
    'interfaces': 'Interfaces',
    'enums': 'Enums',
    'type-aliases': 'Type Aliases',
    'classes': 'Classes',
    'functions': 'Functions',
    'deprecated': 'Deprecated',
    'dependencies': 'Dependencies',
    'notes': 'Notes',
  };

  const TypeScriptDocumentationTemplate({
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

  factory TypeScriptDocumentationTemplate.moduleFor(String title) {
    return TypeScriptDocumentationTemplate(
      name: 'typescript_module',
      title: title,
      layout: DocumentationContract.templateLayoutModule,
      sectionOrder: defaultSectionOrder,
      headings: defaultHeadings,
    );
  }

  factory TypeScriptDocumentationTemplate.controllerFor(String title) {
    return TypeScriptDocumentationTemplate(
      name: 'typescript_controller',
      title: title,
      layout: DocumentationContract.templateLayoutController,
      sectionOrder: defaultSectionOrder,
      headings: defaultHeadings,
    );
  }
}
