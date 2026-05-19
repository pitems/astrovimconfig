# Documentation: markdown_document_renderer

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/renderers/markdown_document_renderer.dart`
- Documentation: `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/renderers/markdown_document_renderer.md`
- Generated: `2026-05-14T22:18:17.032822Z`

## Classes

### MarkdownDocumentRenderer

#### Variables

##### ManualBodySanitizer _manualBodySanitizer
Holds the language-specific sanitizer selected for the current render pass. It is swapped per document so Dart and TypeScript can preserve notes differently.

#### Functions

##### String render(DocumentationResult result, {String? existingMarkdown})
This is the main render entry point. It takes the normalized analysis result plus any existing markdown, then rebuilds the page while preserving human notes and updating renamed or removed symbols.

##### void _renderOverview(StringBuffer buffer, DocumentationResult result, String heading)
Writes the file-level summary block. This is where the language, source path, doc path, and timestamp are shown at the top of the page.

##### void _renderVariables(StringBuffer buffer, String heading, List<DocumentationSymbol> variables, Map<String, _ExistingEntry> existingVariables)
Renders top-level variables and reuses any old body notes attached to the same symbol name.

##### void _renderSymbols(StringBuffer buffer, String heading, List<DocumentationSymbol> symbols, List<_ExistingEntry> existingEntries)
Generic symbol renderer for sections that do not need special TS/Vue handling.

##### void _renderTypeScriptSymbols(StringBuffer buffer, String heading, List<DocumentationSymbol> symbols, Map<String, _ExistingEntry> existingEntries, {required String kindLabel})
Renders TS-specific symbol groups like interfaces, enums, and type aliases, then appends any preserved human-written notes below the generated scaffold.

##### void _renderClasses(StringBuffer buffer, String heading, List<DocumentationSymbol> classes, _ExistingMarkdown existing, Map<String, _ExistingEntry> classRenameMatches, Map<String, String> classOwnerNames, Map<String, _ExistingEntry> classMemberRenameMatches)
Renders the class section and inserts separators between class blocks. It also passes rename and ownership metadata down to the nested class members.

##### void _renderClassTree(StringBuffer buffer, DocumentationSymbol classSymbol, {required int level, required _ExistingMarkdown existing, required Map<String, _ExistingEntry> classRenameMatches, required Map<String, String> classOwnerNames, required Map<String, _ExistingEntry> classMemberRenameMatches})
Renders one class and then recursively renders its member groups. This is the core of the controller-style layout.

##### bool _isClassRenderableMember(DocumentationSymbol symbol)
Checks whether a symbol belongs in a class member group rather than the top level.

##### _ExistingEntry? _detectClassRename(DocumentationSymbol currentClass, List<_ExistingEntry> existingClasses, Map<String, List<_ExistingEntry>> existingClassMembersByClass, Set<String> exactClassNames)
Compares the current class against earlier docs to decide whether the file was renamed instead of deleted and recreated.

##### double _classSimilarity(DocumentationSymbol currentClass, _ExistingEntry candidate, List<_ExistingEntry> existingClassMembers)
Scores how close a current class is to an old class using fields, methods, and constructors as the comparison signal.

##### double _groupWeight(int currentCount, int existingCount)
Chooses how much a member group should influence the similarity score.

##### double _setSimilarity(Set<String> a, Set<String> b)
Measures overlap between two structural sets such as signatures or field names.

##### double _countSimilarity(int a, int b)
Compares member counts when the shape is more important than the exact names.

##### String _memberStructuralKeyFromSymbol(DocumentationSymbol symbol)
Builds a canonical comparison key from a live symbol.

##### String _memberStructuralKeyFromHeading(String heading)
Builds the same comparison key from an existing markdown heading so old docs can be compared to new source.

##### String _classMemberGroup(String kind)
Maps child symbol kinds into the class member sections used by the renderer.

##### String _classMemberKey(String className, String group, String name)
Builds the internal lookup key used to match class members during updates.

##### void _renderClassMemberGroup(StringBuffer buffer, int headingLevel, String heading, String currentClassName, String ownerName, String group, List<DocumentationSymbol> members, _ExistingMarkdown existing, Map<String, _ExistingEntry> classMemberRenameMatches)
Renders one class member section such as `Variables`, `Constructors`, or `Functions`.

##### void _writeGeneratedTypeScriptBody(StringBuffer buffer, DocumentationSymbol symbol, String kindLabel)
Writes the auto-generated TS/Vue scaffold lines before any preserved manual note body is appended.

##### List<String> _generatedTypeScriptBodyLines(DocumentationSymbol symbol, String kindLabel)
Builds the lines that are considered generated-only for TS and JS documents.

##### List<String> _stripGeneratedTypeScriptBody(List<String> bodyLines, List<String> generatedLines)
Removes previously generated TS scaffold text from an old body so only human-written notes remain.

##### void _renderFunctions(StringBuffer buffer, String heading, List<DocumentationSymbol> functions, Map<String, _ExistingEntry> existingFunctions, Map<String, _ExistingEntry> renameMatches)
Renders top-level functions and preserves old notes or rename history when the name changes.

##### void _renderDeprecated(StringBuffer buffer, String heading, List<_ExistingEntry> entries)
Renders archived symbols that disappeared from the current source but are kept as history.

##### void _renderDependencies(StringBuffer buffer, String heading, List<Map<String, dynamic>> dependencies, List<DocumentationReference> references, String projectRoot, String sourcePath)
Renders internal project links and creates placeholder docs when a dependency target does not exist yet.

##### void _renderNotes(StringBuffer buffer, String heading, List<String> warnings)
Renders the analyzer notes or warnings section at the bottom of the doc.

##### void _writeParameters(List<DocumentationParameter> parameters, StringBuffer buffer)
Writes the parameter block under a function when the signature needs extra explanation.

##### void _writeManualBody(StringBuffer buffer, List<String>? bodyLines)
Re-inserts preserved human notes after sanitizing out generated-only lines.

##### void _writeRenameNote(StringBuffer buffer, String originalName)
Writes the small italic rename note that tells you what symbol this doc used to belong to.

##### Map<String, _ExistingEntry> _detectRenames({required List<DocumentationSymbol> currentFunctions, required List<_ExistingEntry> existingEntries, required Set<String> exactFunctionNames, double minScore = 0.35})
Matches renamed functions by comparing structural signatures and name similarity.

##### ManualBodySanitizer _sanitizerFor(String language)
Chooses the language-specific sanitizer so Dart and TypeScript keep different preservation rules.

##### String _symbolHeading(DocumentationSymbol symbol)
Builds the markdown heading line for one symbol.

##### String _symbolLabel(DocumentationSymbol symbol)
Chooses the displayed label for a symbol, preferring signatures when they exist.

##### String _headingFor(String section)
Converts a section key into the visible markdown heading text.

##### String _signatureKeyFromSymbol(DocumentationSymbol symbol)
Creates a canonical signature key from a live symbol for rename comparison.

##### String _signatureKeyFromHeading(String heading)
Creates the same canonical signature key from an existing markdown heading.

##### String _canonicalParameterFromModel(DocumentationParameter parameter)
Normalizes a parameter from the in-memory model into a comparison key.

##### String _canonicalParameterFromText(String text, {required bool named})
Normalizes a raw parameter string from markdown into a comparison key.

##### String _fieldSignatureKeyFromSymbol(DocumentationSymbol symbol)
Builds a comparison key for a field symbol.

##### String _fieldSignatureKeyFromHeading(String heading)
Builds a comparison key for a field heading in existing markdown.

##### String _normalizeType(String value)
Normalizes type text so small formatting differences do not break comparison matching.

##### String _ensureDeprecatedHeading(String heading)
Makes sure archived entries are marked as deprecated in the heading itself.

##### String _deprecatedDisplayHeading(_ExistingEntry entry)
Formats the visible heading for a deprecated symbol, including its class owner when needed.

##### String _normalizeHeading(String heading)
Reduces a markdown heading to a comparison-friendly form.

##### _ParsedHeading? _parseHeading(String heading)
Parses a heading back into return type, name, and parameter text so the old body can be matched to the new source.

##### List<String> _splitParameters(String parameters)
Splits a parameter list without losing the nested text that matters for rename comparison.

##### double _nameSimilarity(String a, String b)
Scores how close two names are using edit distance.

##### int _levenshtein(String a, String b)
Computes the edit distance used by the rename matcher.

##### String _today()
Returns the current date string used for removal notes.

##### _ResolvedReference? _resolveReference(DocumentationReference reference, String sourcePath)
Turns a dependency reference into a resolved link target, including the mirrored doc path.

##### void _ensurePlaceholderDoc(String docPath, String title, String sourcePath)
Creates a placeholder doc for an internal dependency the first time it appears.

##### String _docPathForSourcePath(String sourcePath, String currentSourcePath)
Mirrors a referenced source file under `documentation/` relative to the current document tree.

##### bool _isInsideProject(String path, String projectRoot)
Checks whether a resolved file belongs to the current project before linking it.

##### String _guessProjectRoot(String sourcePath)
Finds the project root for a dependency target when the current document does not already know it.

---

### _ResolvedReference

Represents a dependency target after it has been resolved against the current source tree.

#### Variables

##### final String name
The dependency name used in the markdown link.

##### final String sourcePath
The resolved source file path for the dependency target.

##### final String docPath
The mirrored documentation path for that dependency target.

##### final bool exists
Tracks whether the target documentation file already exists on disk.

##### final String title
The placeholder title used when a dependency doc has to be created.

#### Constructors

##### const _ResolvedReference({required this.name, required this.sourcePath, required this.docPath, required this.exists, required this.title})

---

### _ExistingMarkdown

This is the parsed view of the previous markdown file. It lets the renderer reuse old bodies, find renamed sections, and decide what belongs in `Deprecated`.

#### Variables

##### final List<_ExistingEntry> entries
All parsed headings and their preserved body text from the current markdown file.

#### Constructors

##### const _ExistingMarkdown({required this.entries})

##### const _ExistingMarkdown.empty()

##### factory _ExistingMarkdown.parse(String? markdown)

#### Functions

##### bool get hasClassStructure
Checks whether the previous document already had a class tree so controller migrations can be handled differently from flat module docs.

##### String _sectionKeyFromHeading(String heading)
Normalizes a markdown heading into the internal section key used by the parser.

##### String _extractNameFromHeading(String heading)
Pulls the symbol name out of a markdown heading.

##### String _extractClassName(String heading)
Extracts the owning class name from a class-member heading.

##### String _classGroupKey(String heading)
Detects whether a heading belongs to `Variables`, `Constructors`, or `Functions`.

##### _ExistingEntry? classMemberEntry(String className, String group, String name)
Finds an existing class member body by class name, group, and symbol name.

##### _ExistingEntry? classEntry(String className)
Finds the existing body for a class-level section or a deprecated class entry.

##### String? _extractRemovedOn(List<String> bodyLines)
Pulls the removal date from a deprecated body if one has already been written.

---

### _ExistingEntry

Represents one previously rendered markdown section together with its preserved body text.

#### Variables

##### final String section
The normalized section key such as `functions`, `classes`, or `deprecated`.

##### final String heading
The original markdown heading text.

##### final String name
The symbol name extracted from the heading.

##### final List<String> bodyLines
The preserved notes that were found under the heading.

##### final String? removedOn
The archived removal date when the entry was moved into `Deprecated`.

##### final String? className
The owning class for a class member or deprecated class member.

##### final String? subgroup
The class member subgroup such as `variables` or `functions`.

#### Constructors

##### const _ExistingEntry({required this.section, required this.heading, required this.name, required this.bodyLines, this.removedOn, this.className, this.subgroup})

---

### _ParsedHeading

Stores a parsed function-style heading so the renderer can compare old and new signatures.

#### Variables

##### final String returnType
The leading return type found in the heading.

##### final String name
The function or symbol name extracted from the heading.

##### final List<String> parameters
The parameter text extracted from the heading.

#### Constructors

##### const _ParsedHeading({required this.returnType, required this.name, required this.parameters})

---

### _RenameCandidate

#### Variables

##### final String currentName

##### final _ExistingEntry existing

##### final double score

#### Constructors

##### const _RenameCandidate({required this.currentName, required this.existing, required this.score})

---

### _DependencyLink

#### Variables

##### final String name

##### final String docPath

##### final bool exists

#### Constructors

##### const _DependencyLink({required this.name, required this.docPath, required this.exists})


## Deprecated

_No deprecated entries yet._

## Dependencies

- [documentation_contract](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/contracts/documentation_contract.md)
- [documentation_parameter](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_parameter.md)
- [documentation_result](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_result.md)
- [documentation_symbol](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_symbol.md)
- [manual_body_sanitizer](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/renderers/manual_body_sanitizer.md)
