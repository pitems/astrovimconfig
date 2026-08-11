# Codex Context

## What This Project Is

This is a Neovim-based documentation system that generates and maintains markdown docs from source code.

The goal is to keep docs mirrored to source files, update them safely over time, and preserve manual learning notes when possible.

## Current Architecture

### Main flow

- Neovim provides the active source file, filetype, and target doc path.
- A Dart CLI orchestrates the documentation flow.
- The CLI dispatches to language-specific analyzers using a strategy pattern.
- Each analyzer returns normalized JSON.
- A renderer turns that JSON into markdown.
- A hidden root index tracks document identity, layout, and last-known symbol snapshot.

### Hidden index

The index lives in:

- `documentation/.index.json`

It stores:

- `doc_id`
- `source_path`
- `doc_path`
- `layout`
- `fingerprint`
- `snapshot`
- `updated_at`

This is used to:

- detect file renames
- detect symbol changes
- keep doc paths stable
- avoid cluttering markdown with machine metadata

## Dart Side

### Status

Dart documentation is effectively done for the current scope.

### Current rules

- Controller-style files get a controller layout.
- Module-style files get a generic layout.
- `Cubit` is treated like controller-style content.
- Class members are nested under their class instead of being flattened.
- Top-level variables/functions only appear if they actually exist.
- Removed functions go to `Deprecated`.
- Removed variables disappear.
- Renames keep the old context attached with a rename note.

### Important Dart conventions

- `Variables`, `Functions`, and `Deprecated` are the main structure for module files.
- Controller files can contain class-owned `Variables`, `Constructors`, and `Functions`.
- Internal project dependencies are mirrored into `documentation/` and linked.
- External SDK or package imports are ignored as documentation targets.

## TypeScript / JavaScript Side

### Status

The TS/JS side uses a Node backend with the TypeScript compiler API.

### Supported styles

- `ts`
- `tsx`
- `js`
- `jsx`
- `javascript`
- `javascriptreact`
- Vue-style JS with `Vue.createApp(...)`

### Current parser structure

The backend is split into strategies:

- plain JS strategy
- Vue strategy
- shared signature helper

The parsing goal is the same as Dart:

- normalize symbols into a common JSON contract
- let the renderer handle markdown output

### TS/JS symbol support

- classes
- interfaces
- enums
- type aliases
- functions
- variables
- internal imports

## Markdown Docs

### Human notes

Manual documentation should stay readable and separate from generated metadata.

Recommended blocks:

- `**Notes**`
- `**Warning**`
- `**Examples**`

### Current markdown formatting

- `leader lp` reflows markdown paragraphs based on the current split width.
- The wrap width is derived from the active window, not the whole screen.
- Code formatting stays separate from markdown reflow.

### Surround / insert helpers

The `mini.surround` plugin is exposed through the Neovim menu so it is easier to discover.

## Vue Learning Notes

The Vue example in `/Users/pitems/Dev/Vue/startup/app.js` is used as a learning doc.

Important idea:

- `handleEvent(e, number)` receives the Vue event object first.
- `$event` is how the template passes the actual event into the handler.
- A second argument like `5` is optional extra data.

Good explanation style:

- use simple analogies
- keep wording readable
- explain the "why" and "how" instead of only naming the symbol

## Key Files

- `tools/documentation_cli/lib/src/cli_app.dart`
- `tools/documentation_cli/lib/src/analyzers/dart/dart_analyzer.dart`
- `tools/documentation_cli/lib/src/renderers/markdown_document_renderer.dart`
- `tools/documentation_cli/lib/src/index/documentation_index.dart`
- `tools/documentation_cli/typescript_backend/src/parser.js`
- `tools/documentation_cli/typescript_backend/src/strategies/`

## Good Next Steps

- Continue adding self-documentation to the CLI internals.
- Expand the TypeScript side with more real project samples.
- Keep the index small and current.
- Use this file as the short reset context for future sessions.
