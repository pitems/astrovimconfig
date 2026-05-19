import 'package:analyzer/dart/ast/ast.dart';

import '../../../../models/documentation_symbol.dart';
import '../dart_visitor_context.dart';

void collectTopLevelVariableDeclaration(
  TopLevelVariableDeclaration node,
  DartVisitorContext context,
) {
  // Top-level variables are part of the public-facing documentation surface.
  // We intentionally ignore local variables because they are implementation
  // details, not durable module-level API.
  final typeAnnotation = node.variables.type?.toSource();
  for (final variable in node.variables.variables) {
    context.addSymbol(
      DocumentationSymbol(
        kind: 'variable',
        name: variable.name.lexeme,
        typeAnnotation: typeAnnotation,
        visibility: context.visibility(variable.name.lexeme),
        lineStart: context.lineNumber(variable.offset),
        lineEnd: context.lineNumber(variable.end),
        metadata: <String, dynamic>{
          'isConst': node.variables.isConst,
          'isFinal': node.variables.isFinal,
          'isLate': node.variables.isLate,
        },
      ),
    );
  }
}
