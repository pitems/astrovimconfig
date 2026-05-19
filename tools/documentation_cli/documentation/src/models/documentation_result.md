# Documentation: documentation_result

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/models/documentation_result.dart`
- Documentation: `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_result.md`
- Generated: `2026-05-14T22:18:34.443017Z`

## Classes

### DocumentationResult

Carries the fully normalized result returned by an analyzer. This object is the handoff between parsing and markdown rendering.

#### Variables

##### final String language
The language the analyzer resolved for this source file. It lets the renderer choose the right sanitizer and layout behavior.

##### final String sourcePath
The source file being documented. This is the original code file, not the mirrored markdown file.

##### final String docPath
The mirrored markdown file that should receive the rendered output.

##### final String? projectRoot
The root used for path mirroring and internal dependency resolution. When it is `null`, the tool falls back to project detection.

##### final DocumentationTemplate template
The layout and headings that control how markdown is rendered. The template decides whether the output looks like a module or a controller document.

##### final List<DocumentationSymbol> symbols
The extracted symbol tree from the source file. This is the core content the renderer turns into sections and headings.

##### final List<Map<String, dynamic>> dependencies
Normalized internal dependencies used to build links and placeholders. These are the relationships the renderer turns into internal markdown links.

##### final List<DocumentationReference> references
Reference metadata for dependency resolution and link generation. The references keep track of the original source target and whether a doc already exists.

##### final DocumentationMetadata metadata
Timestamp and analyzer details for the generated output. This is what you inspect when you want to know how the doc was produced.

##### final List<String> warnings
Analyzer or rendering notes that should appear under `Notes`. These are the messages that survive into the human-facing markdown.

#### Constructors

##### const DocumentationResult({required this.language, required this.sourcePath, required this.docPath, required this.projectRoot, required this.template, required this.symbols, required this.dependencies, required this.metadata, this.references = const <DocumentationReference>[], this.warnings = const <String>[]})

##### factory DocumentationResult.fromJson(Map<String, dynamic> json)

#### Functions

##### Map<String, dynamic> toJson()
Serializes the result to the JSON contract consumed by the renderer and CLI. This is the payload passed between command steps and external tools.

---

### DocumentationReference

Describes an internal source target that can be linked or placeholder-created. This is how the renderer knows where to create or point a dependency link.

#### Variables

##### final String name

##### final String sourcePath

##### final String docPath

##### final bool exists

##### final String kind

#### Constructors

##### const DocumentationReference({required this.name, required this.sourcePath, required this.docPath, required this.exists, required this.kind})

##### factory DocumentationReference.fromJson(Map<String, dynamic> json)

#### Functions

##### Map<String, dynamic> toJson()
Serializes the reference for transport across the CLI boundary so the dependency resolution step can stay language-agnostic.


## Deprecated

_No deprecated entries yet._

## Dependencies

- [documentation_contract](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/contracts/documentation_contract.md)
- [documentation_metadata](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_metadata.md)
- [documentation_symbol](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_symbol.md)
- [documentation_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_template.md)
