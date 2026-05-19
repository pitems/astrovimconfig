# Documentation: cli_app

## Overview

- Language: `dart`
- Source:
  `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/cli_app.dart`
- Documentation:
  `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/cli_app.md`
- Generated: `2026-05-14T22:18:17.022421Z`

## Classes

### CliApplication

This is the entry point for the CLI. It receives raw arguments, converts
them into a request, and then chooses whether to analyze, render, create, or
emit reusable note blocks.

#### Variables

##### final DocumentationOrchestrator orchestrator

## **Notes**

Owns the command-to-analyzer handoff. When `create` or `analyze` runs, this
is the object that resolves the correct language analyzer and returns the
normalized result.

##### final MarkdownDocumentRenderer renderer

Turns the normalized analysis result back into markdown. It also merges
existing notes and preserves human-written content where possible.

##### final NoteBlockRegistry noteBlockRegistry

Builds the reusable `Notes`, `Warning`, `Examples`, and symbol block
templates that Neovim inserts into markdown buffers.

#### Constructors

##### CliApplication({DocumentationOrchestrator? orchestrator,

MarkdownDocumentRenderer? renderer})

#### Functions

##### Future<int> run(List<String> arguments, {String? stdinText})

This is the dispatcher for the entire CLI. It parses the command name,
validates the flags, and routes to the proper subcommand while keeping the
error handling in one place.

##### Future<int> \_runAnalyze(\_ParsedOptions parsed)

Runs analysis only and prints the normalized JSON contract to stdout. This
is the quickest way to inspect what the analyzer discovered without writing
markdown.

##### Future<int> \_runRender(\_ParsedOptions parsed, {String? stdinText})

Consumes a JSON result and renders it into markdown. It is used when the
JSON already exists, either from a file or from piped stdin.

##### Future<int> \_runCreate(\_ParsedOptions parsed)

This is the main end-to-end path. It analyzes the source, loads the existing
doc if one exists, renders the updated markdown, writes it out, and updates
the hidden index.

##### Future<int> \_runBlocks(\_ParsedOptions parsed)

Returns a reusable markdown note block. This is the path the editor uses
when it wants a quick insertable template instead of a full document
generation run.

##### DocumentationRequest \_buildRequest(\_ParsedOptions parsed)

Builds the internal request object from CLI flags. It also derives the
mirrored documentation path so callers do not need to compute it themselves.

##### String \_docPathForSource(String sourcePath, {String? projectRoot})

Mirrors the source path under `documentation/` so docs stay aligned with the
original tree structure.

##### String \_guessProjectRoot(String sourcePath)

Tries to find the package root from the source location. This lets the tool
work whether the file lives under `lib/` or at the project root.

##### Future<void> \_writeMaybe(String? outputPath, String content)

Writes markdown to a file or prints it to stdout when the output path is
`-`. This keeps the CLI useful for both terminal review and file generation.

##### Future<String?> \_readExistingFile(String path)

Reads an existing markdown file if it exists so the renderer can preserve
manual notes and previous structure.

##### Future<void> \_removeFileIfExists(String path)

Deletes the old doc when the source file has moved and the index has chosen
a new location.

##### void \_printHelp()

Prints the command list and the supported flags. It exists so the CLI can
fail with a usable help screen instead of a bare error.

---

### \_ParsedOptions

#### Variables

##### final Map<String, String?> options

#### Constructors

##### \_ParsedOptions(this.options)

#### Functions

##### String? value(String key)

Returns an optional argument value, or `null` when the key is not present.
It is used for flags that are allowed to be omitted, like `--project-root`
or `--template`.

##### String required(String key)

Returns the argument value and throws when a required key is missing. This
keeps the command handlers small because they can assume mandatory flags
already exist.

## Functions

### \_ParsedOptions \_parseOptions(List<String> args)

**Parameters**

- `args` (List<String>): ---- Parses the flat `--key value` / `--key=value`
  argument list into a simple map. It intentionally ignores bare positional
  extras so the command parser stays forgiving.

## Deprecated

_No deprecated entries yet._

## Dependencies

- [documentation_index](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/index/documentation_index.md)
- [documentation_request](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_request.md)
- [documentation_result](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_result.md)
- [documentation_orchestrator](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/orchestrator/documentation_orchestrator.md)
- [note_block_registry](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/note_block_registry.md)
- [markdown_document_renderer](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/renderers/markdown_document_renderer.md)
