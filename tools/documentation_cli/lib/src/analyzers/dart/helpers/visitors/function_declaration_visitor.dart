import 'package:analyzer/dart/ast/ast.dart';

import '../../../../models/documentation_symbol.dart';
import '../dart_visitor_context.dart';

void collectFunctionDeclaration(
  FunctionDeclaration node,
  DartVisitorContext context,
) {
  // Top-level functions are part of the module API, so we only collect
  // declarations that live directly under the compilation unit.
  if (node.parent is! CompilationUnit) {
    return;
  }

  // Only document top-level functions here; class methods are handled separately.
  final name = node.name.lexeme;
  context.addSymbol(
    DocumentationSymbol(
      kind: 'function',
      name: name,
      signature: context.signatureBuilder.buildFunctionSignature(
        returnType: node.returnType?.toSource(),
        name: name,
        parameters: node.functionExpression.parameters?.toSource(),
        isGetter: node.isGetter,
        isSetter: node.isSetter,
      ),
      returnType:
          node.returnType?.toSource() ?? (node.isGetter ? null : 'void'),
      visibility: context.visibility(name),
      lineStart: context.lineNumber(node.offset),
      lineEnd: context.lineNumber(node.end),
      parameters: context.parameterParser
          .extractParameters(node.functionExpression.parameters),
      metadata: <String, dynamic>{
        'isGetter': node.isGetter,
        'isSetter': node.isSetter,
        'isExternal': node.externalKeyword != null,
      },
    ),
  );
}
