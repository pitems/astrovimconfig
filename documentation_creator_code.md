# Documentation Creator Context

This file is a clean handoff for the Neovim documentation generator work.
Use it as the starting context in a new conversation.

## Goal

Build an automatic documentation system inside Neovim that reads source code and generates or updates markdown docs for it.

The original intent was "AST-based", but the current implementation is mostly:
- Dart/Flutter-focused
- regex-based
- partially finished

## Current State

The main entrypoint is:
- `lua/documentation/documentation_creator.lua`

It:
- looks at the current source buffer
- finds a documentation path under `documentation/`
- checks the current filetype
- uses a parser from `lua/documentation/doc_parsers/`
- builds or updates markdown docs

Only `dart` is currently registered as a parser.

## Relevant Files

- `lua/documentation/documentation_creator.lua`
- `lua/documentation/doc_parsers/init.lua`
- `lua/documentation/doc_parsers/dart.lua`
- `lua/documentation/finders/function_finder.lua`
- `lua/documentation/finders/variable_finder.lua`
- `lua/documentation/finders/dependency_finder.lua`
- `lua/documentation/documents_utils.lua`
- `lua/documentation/config/renderer.lua`
- `lua/documentation/config/headers.lua`
- `lua/documentation/preview_renderer.lua`
- `lua/documentation/rename.lua`
- `lua/documentation/doc_sync.lua`
- `lua/documentation/ui/dependency_picker.lua`

## What Works Now

- Generates markdown docs for Dart files.
- Extracts:
  - functions
  - variables
  - package dependencies
- Can update existing docs when functions are added, removed, or renamed.
- Uses a markdown renderer to build structured docs.

## What Is Still Limited

- Only Dart is wired in `doc_parsers/init.lua`.
- The parser is regex/scope based, not a true AST parser.
- `doc_sync.lua` looks unfinished and has path/API mismatches.
- The system is not yet generalized for Lua, TypeScript, Python, etc.

## Important Behavior

When a Dart file is opened through the docs creator:
- docs are stored under `documentation/<relative-path>.md`
- if the doc exists, it compares source vs doc
- if the doc does not exist, it prompts to create one

The docs structure currently includes sections like:
- Overview
- Variables
- Functions
- Dependencies

## Existing Neovim Integration

The docs creator is exposed through keybindings in:
- `lua/keybinds/groups/documentation.lua`

Current mappings:
- `<leader>Dd` open/create documentation for the current file
- `<leader>Da` open dependencies for the current markdown doc

## Known Issues / Cleanup Targets

- `doc_sync.lua` imports incorrect module paths and references undefined variables.
- `rename.lua` has duplicated/fragile logic and should be reviewed before relying on it.
- The parser layer should be split into language-specific modules if we want more than Dart.
- If the goal is real AST support, tree-sitter or language-specific parsers should replace regex heuristics.

## Good Next Directions

Choose one of these before expanding:

1. Stabilize the existing Dart/Flutter doc generator.
2. Convert the parser layer into a multi-language framework.
3. Replace regex parsing with tree-sitter-based extraction.
4. Clean up the sync/update flow and remove dead code.

## Suggested Fresh Conversation Prompt

Use something like this to start clean:

> I have a Neovim documentation generator in `lua/documentation/`. It currently works only for Dart/Flutter and mostly uses regex-based parsing. I want to continue from a clean context and either stabilize it or redesign it. Please inspect the current code and help me decide the best next step.

