import 'package:analyzer/dart/ast/ast.dart';

import '../../../../models/documentation_symbol.dart';
import '../dart_visitor_context.dart';

void collectClassDeclaration(
  ClassDeclaration node,
  DartVisitorContext context, {
  required void Function() visitChildren,
}) {
  // Open a class frame before descending so nested members attach to the class
  // symbol instead of the top-level document list.
  context.beginClass(
    DocumentationSymbol(
      kind: 'class',
      name: node.name.lexeme,
      visibility: context.visibility(node.name.lexeme),
      lineStart: context.lineNumber(node.offset),
      lineEnd: context.lineNumber(node.end),
      metadata: <String, dynamic>{
        'isAbstract': node.abstractKeyword != null,
        if (node.extendsClause != null)
          'superclass': node.extendsClause!.superclass.toSource(),
      },
    ),
  );

  try {
    visitChildren();
  } finally {
    context.addSymbol(context.endClass());
  }
}
