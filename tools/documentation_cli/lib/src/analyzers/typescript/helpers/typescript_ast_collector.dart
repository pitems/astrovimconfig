/// Placeholder for the real TypeScript symbol collector.
///
/// The Dart side uses a dedicated AST visitor. The TypeScript side will follow
/// the same pattern, but the concrete parser backend is still to be selected.
class TypeScriptAstCollector {
  TypeScriptAstCollector({
    required this.sourceText,
  });

  final String sourceText;

  Map<String, dynamic> collect() {
    // Keep this intentionally empty for the scaffold version.
    return <String, dynamic>{
      'classes': <Map<String, dynamic>>[],
      'variables': <Map<String, dynamic>>[],
      'functions': <Map<String, dynamic>>[],
      'dependencies': <Map<String, dynamic>>[],
    };
  }
}
