# Documentation CLI

This Dart project is the language-analysis layer for the Neovim documentation generator.

## Responsibility Split

- Neovim computes the source file and documentation path.
- This CLI analyzes the source file with a language-specific backend.
- The backend returns normalized JSON.
- A renderer turns that JSON into markdown.

## Commands

### Analyze

Outputs normalized JSON to stdout.

```bash
dart run bin/documentation_cli.dart analyze \
  --source /path/to/file.dart \
  --doc-path /path/to/documentation/file.md \
  --filetype dart
```

### Create

Analyzes the source file and renders markdown.

```bash
dart run bin/documentation_cli.dart create \
  --source /path/to/file.dart \
  --doc-path /path/to/documentation/file.md \
  --filetype dart \
  --output /path/to/output.md
```

If `--output` is omitted, markdown is written to `--doc-path`.

The CLI will create the parent `documentation/` folders if they do not exist.

### Render

Consumes a JSON document result from a file or stdin and renders markdown.

```bash
dart run bin/documentation_cli.dart render --input result.json
```

or

```bash
cat result.json | dart run bin/documentation_cli.dart render
```

## Structure

- `lib/src/analyzers/` contains the strategy implementations.
- `lib/src/orchestrator/` resolves the right analyzer.
- `lib/src/models/` defines the request/result schema.
- `lib/src/renderers/` turns the result into markdown.
- `schemas/` contains the JSON schema for the normalized result.
