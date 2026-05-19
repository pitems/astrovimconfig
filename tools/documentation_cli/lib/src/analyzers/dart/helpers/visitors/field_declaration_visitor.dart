import 'package:analyzer/dart/ast/ast.dart';

import '../../../../models/documentation_symbol.dart';
import '../dart_visitor_context.dart';

void collectFieldDeclaration(
  FieldDeclaration node,
  DartVisitorContext context,
) {
  // Fields are collected as class members so the generated docs can show the
  // shape of each type, not just its callable surface.
  final typeAnnotation = node.fields.type?.toSource();
  for (final variable in node.fields.variables) {
    context.addSymbol(
      DocumentationSymbol(
        kind: 'field',
        name: variable.name.lexeme,
        typeAnnotation: typeAnnotation,
        visibility: context.visibility(variable.name.lexeme),
        lineStart: context.lineNumber(variable.offset),
        lineEnd: context.lineNumber(variable.end),
        metadata: <String, dynamic>{
          'isStatic': node.isStatic,
          'isConst': node.fields.isConst,
          'isFinal': node.fields.isFinal,
          'isLate': node.fields.isLate,
        },
      ),
    );
  }
}
