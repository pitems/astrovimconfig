import 'package:analyzer/dart/ast/ast.dart';

import '../../../../models/documentation_result.dart';
import '../dart_visitor_context.dart';

void collectImportDirective(ImportDirective node, DartVisitorContext context) {
  // Imports describe the external and internal dependency graph. We only keep
  // internal imports because those can be linked back into the docs.
  final uriValue = node.uri.stringValue ?? node.uri.toSource();
  final internal = context.dependencyResolver.isInternalImport(uriValue);

  // Import directives are kept as dependency metadata, but only internal ones
  // become navigable documentation references.
  if (!internal) {
    return;
  }

  final resolved =
      context.dependencyResolver.resolveInternalReference(uriValue);
  context.addDependency(
    kind: 'import',
    path: uriValue,
    name: uriValue,
    lineStart: node.offset,
    lineEnd: node.end,
    metadata: <String, dynamic>{
      'prefix': node.prefix?.name,
      'internal': true,
    },
  );

  context.addReference(
    DocumentationReference(
      name: resolved.name,
      sourcePath: resolved.sourcePath,
      docPath: resolved.docPath,
      exists: resolved.exists,
      kind: 'import',
    ),
  );
}

void collectExportDirective(ExportDirective node, DartVisitorContext context) {
  // Exports are treated as dependency metadata so the documentation can show
  // which internal sources are re-exposed by this library.
  final uriValue = node.uri.stringValue ?? node.uri.toSource();
  final internal = context.dependencyResolver.isInternalImport(uriValue);
  if (!internal) {
    return;
  }

  context.addDependency(
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

void collectPartDirective(PartDirective node, DartVisitorContext context) {
  // Part directives describe a library split across files, so we keep them to
  // preserve the document structure of the source package.
  final uriValue = node.uri.stringValue ?? node.uri.toSource();
  final internal = context.dependencyResolver.isInternalImport(uriValue);
  if (!internal) {
    return;
  }

  context.addDependency(
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
