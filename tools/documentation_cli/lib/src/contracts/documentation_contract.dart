class DocumentationContract {
  static const String schemaVersion = '1.0.0';
  static const String toolVersion = '0.1.0';
  static const String defaultTemplateName = 'neovim_standard';

  static const List<String> defaultSectionOrder = <String>[
    'overview',
    'variables',
    'classes',
    'functions',
    'deprecated',
    'dependencies',
    'notes',
  ];
}
