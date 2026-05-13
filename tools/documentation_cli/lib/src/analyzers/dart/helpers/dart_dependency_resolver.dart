import 'dart:io';

import '../../../models/documentation_result.dart';

class DartDependencyResolver {
  DartDependencyResolver({
    required this.projectRoot,
    required this.sourcePath,
  }) : packageName = findPackageName(sourcePath);

  final String projectRoot;
  final String sourcePath;
  final String? packageName;

  bool isInternalImport(String uriValue) {
    // External SDK and package imports stay out of the knowledge base.
    if (uriValue.startsWith('dart:')) {
      return false;
    }

    if (uriValue.startsWith('package:')) {
      return packageName != null && uriValue.startsWith('package:$packageName/');
    }

    return uriValue.startsWith('lib/') ||
        uriValue.startsWith('./') ||
        uriValue.startsWith('../') ||
        (!uriValue.contains(':') && uriValue.endsWith('.dart'));
  }

  String referenceNameFromImport(String uriValue) {
    final cleaned = uriValue
        .replaceFirst(RegExp(r'^package:[^/]+/'), '')
        .replaceFirst(RegExp(r'^\.\/'), '')
        .replaceFirst(RegExp(r'^\.\.\/'), '')
        .replaceFirst(RegExp(r'^lib\/'), '');

    final base = cleaned.split('/').last;
    return base.replaceFirst(RegExp(r'\.[^.]+$'), '');
  }

  DocumentationReference resolveInternalReference(String uriValue) {
    final root = projectRoot;
    final sourceDir = File(sourcePath).parent.path;
    final relative = resolveInternalRelativePath(uriValue);
    // Mirror internal references under documentation/ using the same tree shape.
    final sourceAbsolute = resolveInternalSourcePath(uriValue, root, sourceDir, relative);
    final docPath = '$root/documentation/${relative.replaceFirst(RegExp(r'\.[^.]+$'), '')}.md';
    final sourceFileName = relative.split('/').last;

    return DocumentationReference(
      name: sourceFileName.replaceFirst(RegExp(r'\.[^.]+$'), ''),
      sourcePath: sourceAbsolute,
      docPath: docPath,
      exists: File(docPath).existsSync(),
      kind: 'import',
    );
  }

  String resolveInternalRelativePath(String uriValue) {
    final normalized = uriValue
        .replaceFirst(RegExp(r'^package:[^/]+/'), '')
        .replaceFirst(RegExp(r'^\.\./'), '')
        .replaceFirst(RegExp(r'^\./'), '');

    if (normalized.startsWith('lib/')) {
      return normalized.replaceFirst(RegExp(r'^lib/'), '');
    }

    return normalized;
  }

  String resolveInternalSourcePath(
    String uriValue,
    String root,
    String sourceDir,
    String relative,
  ) {
    if (uriValue.startsWith('package:')) {
      final packageRelative = uriValue.replaceFirst(RegExp(r'^package:[^/]+/'), '');
      final path = packageRelative.startsWith('lib/')
          ? packageRelative
          : 'lib/$packageRelative';
      return '$root/$path';
    }

    if (uriValue.startsWith('./') || uriValue.startsWith('../')) {
      return Uri.file(sourcePath).resolveUri(Uri.parse(uriValue)).toFilePath();
    }

    if (uriValue.startsWith('lib/')) {
      return '$root/$uriValue';
    }

    return '$sourceDir/$relative';
  }

  static String? findPackageName(String sourcePath) {
    // Package name is used to decide whether a package: import is internal.
    var dir = File(sourcePath).parent;
    while (true) {
      final pubspec = File('${dir.path}/pubspec.yaml');
      if (pubspec.existsSync()) {
        for (final line in pubspec.readAsLinesSync()) {
          final match = RegExp(r'^name:\s*(\S+)').firstMatch(line);
          if (match != null) {
            return match.group(1);
          }
        }
      }

      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }

    return null;
  }
}
