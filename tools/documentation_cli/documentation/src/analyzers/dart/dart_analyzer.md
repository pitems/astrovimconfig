# Documentation: dart_analyzer

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/analyzers/dart/dart_analyzer.dart`
- Documentation: `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/analyzers/dart/dart_analyzer.md`
- Generated: `2026-05-14T22:18:17.022333Z`

## Classes

### DartAnalyzer

This analyzer owns the Dart-specific path from source file to normalized documentation data. It is responsible for parsing Dart, collecting symbols, deciding the layout, and packaging everything into the shared result format.

#### Functions

##### String get language
Returns the analyzer name used in the final result payload so the renderer and CLI can identify the source language later.

##### bool supports(String fileType)
Checks whether the incoming file type should be routed to the Dart analyzer. Only Dart file types should reach this class because the rest of the logic assumes Dart AST nodes.

##### Future<DocumentationResult> analyze(DocumentationRequest request)
Parses the Dart source, builds the symbol tree, pulls in dependency metadata, and returns the normalized documentation result used by the rest of the tool.

##### String _baseName(String sourcePath)
Returns the file name without its extension so the generated title and doc identity stay readable.

##### String _baseNameWithoutExtension(String sourcePath)
Returns a clean title base for docs and file naming. This is the string used when the renderer creates `Documentation: <name>`.

##### String _projectRootForSource(String sourcePath)
Finds the package root that owns the source file. That root is later used for mirroring paths under `documentation/` and resolving internal dependency links.

##### DocumentationTemplate _templateFor({required String layout, required String title})
Chooses the correct markdown layout for module or controller-shaped Dart files. The layout determines which sections appear and how classes versus top-level symbols are grouped.

##### String _detectLayout(List<DocumentationSymbol> symbols)
Decides whether the file should render as a controller or a plain module by looking at class ownership, member count, and the naming pattern of the main class.

##### bool _classInheritanceSuggestsController(DocumentationSymbol classSymbol)
Treats Cubit, Bloc, and similar inheritance chains as controller-style sources even when the class name itself is not a classic `Controller` suffix.


## Deprecated

_No deprecated entries yet._

## Dependencies

- [documentation_contract](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/contracts/documentation_contract.md)
- [documentation_metadata](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_metadata.md)
- [documentation_request](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_request.md)
- [documentation_result](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_result.md)
- [documentation_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_template.md)
- [documentation_symbol](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_symbol.md)
- [document_analyzer](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/analyzers/document_analyzer.md)
- [dart_ast_collector](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/analyzers/dart/helpers/dart_ast_collector.md)
