import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

import '../../../models/documentation_result.dart';
import '../../../models/documentation_symbol.dart';
import 'dart_dependency_resolver.dart';
import 'dart_parameter_parser.dart';
import 'dart_signature_builder.dart';

class DartAstCollector extends RecursiveAstVisitor<void> {
  DartAstCollector(
    this.lineInfo, {
    required this.projectRoot,
    required this.sourcePath,
  }) : dependencyResolver = DartDependencyResolver(
         projectRoot: projectRoot,
         sourcePath: sourcePath,
       );

  final LineInfo lineInfo;
  final String projectRoot;
  final String sourcePath;
  final DartDependencyResolver dependencyResolver;
  final DartParameterParser parameterParser = DartParameterParser();
  final DartSignatureBuilder signatureBuilder = DartSignatureBuilder();
  final List<_ClassFrame> _classStack = <_ClassFrame>[];

  final List<DocumentationSymbol> symbols = <DocumentationSymbol>[];
  final List<Map<String, dynamic>> dependencies = <Map<String, dynamic>>[];
  final List<DocumentationReference> references = <DocumentationReference>[];

  @override
  void visitImportDirective(ImportDirective node) {
    final uriValue = node.uri.stringValue ?? node.uri.toSource();
    final internal = dependencyResolver.isInternalImport(uriValue);
    // Import directives are kept as dependency metadata, but only internal ones
    // become navigable documentation references.
    if (!internal) {
      return;
    }

    final resolved = dependencyResolver.resolveInternalReference(uriValue);
    _addDependency(
      kind: 'import',
      path: uriValue,
      name: uriValue,
      lineStart: node.offset,
      lineEnd: node.end,
      metadata: <String, dynamic>{
        if (node.prefix != null) 'prefix': node.prefix!.name,
        'internal': true,
      },
    );
    if (resolved != null) {
      references.add(
        DocumentationReference(
          name: resolved.name,
          sourcePath: resolved.sourcePath,
          docPath: resolved.docPath,
          exists: resolved.exists,
          kind: 'import',
        ),
      );
    }
  }

  @override
  void visitExportDirective(ExportDirective node) {
    final uriValue = node.uri.stringValue ?? node.uri.toSource();
    final internal = dependencyResolver.isInternalImport(uriValue);
    if (!internal) {
      return;
    }
    _addDependency(
      kind: 'export',
      path: uriValue,
      name: uriValue,
      lineStart: node.offset,
      lineEnd: node.end,
      metadata: <String, dynamic>{
        'internal': true,
      },
    );
  }

  @override
  void visitPartDirective(PartDirective node) {
    final uriValue = node.uri.stringValue ?? node.uri.toSource();
    final internal = dependencyResolver.isInternalImport(uriValue);
    if (!internal) {
      return;
    }
    _addDependency(
      kind: 'part',
      path: uriValue,
      name: uriValue,
      lineStart: node.offset,
      lineEnd: node.end,
      metadata: <String, dynamic>{
        'internal': true,
      },
    );
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.parent is! CompilationUnit) {
      return;
    }

    // Only document top-level functions here; class methods are handled separately.
    final name = node.name.lexeme;
    _addSymbol(
      DocumentationSymbol(
        kind: 'function',
        name: name,
        signature: signatureBuilder.buildFunctionSignature(
          returnType: node.returnType?.toSource(),
          name: name,
          parameters: node.functionExpression.parameters?.toSource(),
          isGetter: node.isGetter,
          isSetter: node.isSetter,
        ),
        returnType: node.returnType?.toSource() ?? (node.isGetter ? null : 'void'),
        visibility: _visibility(name),
        lineStart: _lineNumber(node.offset),
        lineEnd: _lineNumber(node.end),
        parameters: parameterParser.extractParameters(node.functionExpression.parameters),
        metadata: <String, dynamic>{
          'isGetter': node.isGetter,
          'isSetter': node.isSetter,
          'isExternal': node.externalKeyword != null,
        },
      ),
    );
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    // Top-level variables are part of the public-facing documentation surface.
    final typeAnnotation = node.variables.type?.toSource();
    for (final variable in node.variables.variables) {
      _addSymbol(
        DocumentationSymbol(
          kind: 'variable',
          name: variable.name.lexeme,
          typeAnnotation: typeAnnotation,
          visibility: _visibility(variable.name.lexeme),
          lineStart: _lineNumber(variable.offset),
          lineEnd: _lineNumber(variable.end),
          metadata: <String, dynamic>{
            'isConst': node.variables.isConst,
            'isFinal': node.variables.isFinal,
            'isLate': node.variables.isLate,
          },
        ),
      );
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final typeAnnotation = node.fields.type?.toSource();
    for (final variable in node.fields.variables) {
      _addSymbol(
        DocumentationSymbol(
          kind: 'field',
          name: variable.name.lexeme,
          typeAnnotation: typeAnnotation,
          visibility: _visibility(variable.name.lexeme),
          lineStart: _lineNumber(variable.offset),
          lineEnd: _lineNumber(variable.end),
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

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.lexeme;
    // Class methods stay in the same normalized function model as top-level ones.
    _addSymbol(
      DocumentationSymbol(
        kind: node.isGetter ? 'getter' : node.isSetter ? 'setter' : 'function',
        name: name,
        signature: signatureBuilder.buildMethodSignature(
          returnType: node.returnType?.toSource(),
          name: name,
          parameters: node.parameters?.toSource(),
          isGetter: node.isGetter,
          isSetter: node.isSetter,
        ),
        returnType: node.returnType?.toSource() ?? (node.isGetter ? null : 'void'),
        visibility: _visibility(name),
        lineStart: _lineNumber(node.offset),
        lineEnd: _lineNumber(node.end),
        parameters: parameterParser.extractParameters(node.parameters),
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

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final frame = _ClassFrame(
      symbol: DocumentationSymbol(
        kind: 'class',
        name: node.name.lexeme,
        visibility: _visibility(node.name.lexeme),
        lineStart: _lineNumber(node.offset),
        lineEnd: _lineNumber(node.end),
        metadata: <String, dynamic>{
          'isAbstract': node.abstractKeyword != null,
        },
      ),
    );

    _classStack.add(frame);
    try {
      super.visitClassDeclaration(node);
    } finally {
      _classStack.removeLast();
      _addSymbol(
        frame.symbol.copyWith(children: List<DocumentationSymbol>.unmodifiable(frame.children)),
      );
    }
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final name = node.name?.lexeme ?? node.returnType.toSource();
    _addSymbol(
      DocumentationSymbol(
        kind: 'constructor',
        name: name,
        signature: signatureBuilder.buildConstructorSignature(node),
        visibility: _visibility(name),
        lineStart: _lineNumber(node.offset),
        lineEnd: _lineNumber(node.end),
        metadata: <String, dynamic>{
          'isConst': node.constKeyword != null,
          'isFactory': node.factoryKeyword != null,
        },
      ),
    );
    super.visitConstructorDeclaration(node);
  }

  void _addSymbol(DocumentationSymbol symbol) {
    if (_classStack.isNotEmpty) {
      _classStack.last.children.add(symbol);
      return;
    }

    symbols.add(symbol);
  }

  void _addDependency({
    required String kind,
    required String path,
    required String name,
    required int lineStart,
    required int lineEnd,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    dependencies.add(
      <String, dynamic>{
        'kind': kind,
        'path': path,
        'name': name,
        'lineStart': _lineNumber(lineStart),
        'lineEnd': _lineNumber(lineEnd),
        if (metadata.isNotEmpty) 'metadata': metadata,
      },
    );
  }

  int _lineNumber(int offset) => lineInfo.getLocation(offset).lineNumber;

  String _visibility(String name) => name.startsWith('_') ? 'private' : 'public';
}

class _ClassFrame {
  _ClassFrame({required this.symbol});

  final DocumentationSymbol symbol;
  final List<DocumentationSymbol> children = <DocumentationSymbol>[];
}
