import 'package:analyzer/dart/ast/ast.dart';

import '../../../../models/documentation_symbol.dart';
import '../dart_visitor_context.dart';

void collectMethodDeclaration(
  MethodDeclaration node,
  DartVisitorContext context,
) {
  // Class methods, getters, and setters are normalized into one callable
  // symbol model so the renderer can treat them consistently.
  final name = node.name.lexeme;
  // Class methods stay in the same normalized function model as top-level ones.
  context.addSymbol(
    DocumentationSymbol(
      kind: node.isGetter
          ? 'getter'
          : node.isSetter
              ? 'setter'
              : 'function',
      name: name,
      signature: context.signatureBuilder.buildMethodSignature(
        returnType: node.returnType?.toSource(),
        name: name,
        parameters: node.parameters?.toSource(),
        isGetter: node.isGetter,
        isSetter: node.isSetter,
      ),
      returnType:
          node.returnType?.toSource() ?? (node.isGetter ? null : 'void'),
      visibility: context.visibility(name),
      lineStart: context.lineNumber(node.offset),
      lineEnd: context.lineNumber(node.end),
      parameters: context.parameterParser.extractParameters(node.parameters),
      metadata: <String, dynamic>{
        'isStatic': node.isStatic,
        'isAbstract': node.isAbstract,
        'isGetter': node.isGetter,
        'isSetter': node.isSetter,
        'isAsync': node.body.isAsynchronous,
      },
    ),
  );
}
