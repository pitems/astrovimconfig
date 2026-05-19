import 'package:analyzer/dart/ast/ast.dart';

import '../../../../models/documentation_symbol.dart';
import '../dart_visitor_context.dart';

void collectConstructorDeclaration(
  ConstructorDeclaration node,
  DartVisitorContext context,
) {
  // Constructors belong to the owning class and need to be documented as
  // explicit callables so users can see how the type is instantiated.
  final name = node.name?.lexeme ?? node.returnType.toSource();
  context.addSymbol(
    DocumentationSymbol(
      kind: 'constructor',
      name: name,
      signature: context.signatureBuilder.buildConstructorSignature(node),
      visibility: context.visibility(name),
      lineStart: context.lineNumber(node.offset),
      lineEnd: context.lineNumber(node.end),
      metadata: <String, dynamic>{
        'isConst': node.constKeyword != null,
        'isFactory': node.factoryKeyword != null,
      },
    ),
  );
}
