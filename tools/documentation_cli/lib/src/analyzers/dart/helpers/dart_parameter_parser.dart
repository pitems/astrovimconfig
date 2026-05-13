import 'package:analyzer/dart/ast/ast.dart';

import '../../../models/documentation_parameter.dart';

class DartParameterParser {
  List<DocumentationParameter> extractParameters(FormalParameterList? parameters) {
    if (parameters == null) {
      return const <DocumentationParameter>[];
    }

    return parameters.parameters.map((parameter) {
      final source = parameter.toSource();
      final name = _extractParameterName(source);
      final type = _extractParameterType(source, name);

      return DocumentationParameter(
        name: name,
        type: type,
        defaultValue: parameter is DefaultFormalParameter && parameter.defaultValue != null
            ? parameter.defaultValue!.toSource()
            : null,
        isRequired: parameter.isRequired,
        isNamed: parameter.isNamed,
      );
    }).toList();
  }

  String _extractParameterName(String source) {
    final matches = RegExp(r'(?:this\.)?([A-Za-z_]\w*)\s*(?:=|$)').allMatches(source);
    if (matches.isNotEmpty) {
      return matches.last.group(1)!;
    }

    final fallback = RegExp(r'(?:this\.)?([A-Za-z_]\w*)').firstMatch(source);
    return fallback?.group(1) ?? source.trim();
  }

  String? _extractParameterType(String source, String name) {
    final cleaned = source.replaceAll(RegExp(r'\s*=\s*.*$'), '').trim();
    final nameIndex = cleaned.lastIndexOf(name);
    if (nameIndex < 0) {
      return null;
    }

    final withoutName = cleaned.substring(0, nameIndex).trim();
    if (withoutName.isEmpty) {
      return null;
    }

    final tokens = withoutName
        .split(RegExp(r'\s+'))
        .where((token) => token != 'required' && token != 'this' && token != 'this.' && token != 'final' && token != 'covariant')
        .toList();
    if (tokens.isEmpty) {
      return null;
    }

    return tokens.join(' ');
  }
}
