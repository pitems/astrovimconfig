# Documentation: manual_body_sanitizer

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/renderers/manual_body_sanitizer.dart`
- Documentation: `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/renderers/manual_body_sanitizer.md`
- Generated: `2026-05-14T22:18:34.443350Z`

## Classes

### ManualBodySanitizer

Defines the sanitizing contract used to preserve human-written notes during regeneration. Every language-specific sanitizer implements this contract so the renderer can strip generated noise before reusing the old body text.

#### Constructors

##### const ManualBodySanitizer()

#### Functions

##### List<String> sanitize(List<String> bodyLines)
Removes generated noise while keeping authored markdown notes intact. The renderer uses this before it re-inserts preserved notes into the new document.

---

### BaseManualBodySanitizer

Shared sanitizer behavior for languages that do not need extra cleanup rules. It removes obvious machine-generated separators and repeated spacing without touching human-written notes.

#### Constructors

##### const BaseManualBodySanitizer()

#### Functions

##### List<String> sanitize(List<String> bodyLines)
Normalizes spacing and strips obvious generated-only filler lines. This is the default path for Dart and other non-TS languages.

---

### DartManualBodySanitizer

Keeps the Dart path conservative so manual doc text survives updates. Dart docs already have a stable format, so this sanitizer avoids being aggressive.

#### Constructors

##### const DartManualBodySanitizer()

---

### TypeScriptManualBodySanitizer

Adds extra cleanup for generated TS and JS scaffolding in preserved bodies. It knows about TS-specific generated sections like `Extends`, `Properties`, and `Type Aliases`.

#### Constructors

##### const TypeScriptManualBodySanitizer()

#### Functions

##### List<String> sanitize(List<String> bodyLines)
Removes generated TypeScript/Vue scaffold lines before reusing the body. This is what prevents old generated scaffolding from being duplicated when the renderer regenerates a doc.


## Deprecated

_No deprecated entries yet._

## Dependencies

_No internal dependencies detected yet._
