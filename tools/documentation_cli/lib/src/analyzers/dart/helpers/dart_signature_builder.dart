import 'package:analyzer/dart/ast/ast.dart';

class DartSignatureBuilder {
  String buildFunctionSignature({
    required String? returnType,
    required String name,
    required String? parameters,
    required bool isGetter,
    required bool isSetter,
  }) {
    final buffer = StringBuffer();
    if (returnType != null && returnType.isNotEmpty) {
      buffer.write('$returnType ');
    }
    if (isGetter) {
      buffer.write('get $name');
      return buffer.toString();
    }
    if (isSetter) {
      buffer.write('set $name');
      if (parameters != null && parameters.isNotEmpty) {
        buffer.write(parameters);
      }
      return buffer.toString();
    }
    buffer.write(name);
    if (parameters != null && parameters.isNotEmpty) {
      buffer.write(parameters);
    }
    return buffer.toString();
  }

  String buildMethodSignature({
    required String? returnType,
    required String name,
    required String? parameters,
    required bool isGetter,
    required bool isSetter,
  }) {
    return buildFunctionSignature(
      returnType: returnType,
      name: name,
      parameters: parameters,
      isGetter: isGetter,
      isSetter: isSetter,
    );
  }

  String buildConstructorSignature(ConstructorDeclaration node) {
    final buffer = StringBuffer();
    if (node.constKeyword != null) {
      buffer.write('const ');
    }
    if (node.factoryKeyword != null) {
      buffer.write('factory ');
    }
    buffer.write(node.returnType.toSource());
    if (node.name != null) {
      buffer.write('.${node.name!.lexeme}');
    }
    final parameters = node.parameters.toSource();
    if (parameters.isNotEmpty) {
      buffer.write(parameters);
    }
    return buffer.toString();
  }
}
