# Documentation: note_block_registry

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/note_blocks/note_block_registry.dart`
- Documentation: `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/note_block_registry.md`
- Generated: `2026-05-14T22:18:34.442960Z`

## Classes

### NoteBlockRegistry

Resolves the reusable markdown block template for the requested note type. This is the factory the editor uses when it wants to insert a preformatted note, warning, example, or symbol stub.

#### Constructors

##### const NoteBlockRegistry()

#### Functions

##### NoteBlockTemplate create({required String kind, String? name, String? signature, String? intro})
Builds a small reusable block for notes, warnings, examples, or symbol stubs. The `kind` decides which template to build and the optional fields fill in the heading or intro text.


## Deprecated

_No deprecated entries yet._

## Dependencies

- [markdown_note_block](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/markdown_note_block.md)
- [block_class_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/block_class_template.md)
- [block_constructor_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/block_constructor_template.md)
- [block_function_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/block_function_template.md)
- [block_notes_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/block_notes_template.md)
- [block_variable_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/block_variable_template.md)
- [note_block_template](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/note_blocks/note_block_template.md)
