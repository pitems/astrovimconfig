import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

import '../../../models/documentation_result.dart';
import '../../../models/documentation_symbol.dart';
import 'dart_visitor_context.dart';
import 'visitors/class_declaration_visitor.dart';
import 'visitors/constructor_declaration_visitor.dart';
import 'visitors/directive_visitor.dart';
import 'visitors/field_declaration_visitor.dart';
import 'visitors/function_declaration_visitor.dart';
import 'visitors/method_declaration_visitor.dart';
import 'visitors/top_level_variable_declaration_visitor.dart';

class DartAstCollector extends RecursiveAstVisitor<void> {
  DartAstCollector(
    LineInfo lineInfo, {
    required this.projectRoot,
    required this.sourcePath,
  }) : context = DartVisitorContext(
          lineInfo: lineInfo,
          projectRoot: projectRoot,
          sourcePath: sourcePath,
        );

  final DartVisitorContext context;
  final String projectRoot;
  final String sourcePath;

  List<DocumentationSymbol> get symbols => context.symbols;
  List<Map<String, dynamic>> get dependencies => context.dependencies;
  List<DocumentationReference> get references => context.references;

  @override
  void visitImportDirective(ImportDirective node) {
    // Capture internal imports so the documentation output can link related
    // source files and keep dependency metadata for the rendered document.
    collectImportDirective(node, context);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    // Record internal exports as dependency edges so the doc output reflects
    // how this library exposes other source files.
    collectExportDirective(node, context);
  }

  @override
  void visitPartDirective(PartDirective node) {
    // Track internal part directives to show the split file structure behind
    // the documented library.
    collectPartDirective(node, context);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Collect top-level functions only; class methods are handled in a separate
    // visit so the public API surface stays split by scope.
    collectFunctionDeclaration(node, context);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    // Collect only root-level variables so we document the module's public
    // surface instead of local implementation details.
    collectTopLevelVariableDeclaration(node, context);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    // Collect fields declared inside classes so member data appears nested
    // under the owning type in the final symbol tree.
    collectFieldDeclaration(node, context);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // Collect class methods, getters, and setters as normalized callable
    // symbols while preserving member-level metadata.
    collectMethodDeclaration(node, context);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Open a class frame, visit nested members, then close the frame so the
    // collected children remain attached to the owning class symbol.
    collectClassDeclaration(
      node,
      context,
      visitChildren: () => super.visitClassDeclaration(node),
    );
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    // Constructors are class-scoped callables, so they are collected alongside
    // other members before descending into their bodies.
    collectConstructorDeclaration(node, context);
    super.visitConstructorDeclaration(node);
  }
}
