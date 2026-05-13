import 'markdown_note_block.dart';
import 'block_class_template.dart';
import 'block_constructor_template.dart';
import 'block_function_template.dart';
import 'block_notes_template.dart';
import 'block_variable_template.dart';
import 'note_block_template.dart';

class NoteBlockRegistry {
  const NoteBlockRegistry();

  NoteBlockTemplate create({
    required String kind,
    String? name,
    String? signature,
    String? intro,
  }) {
    List<MarkdownNoteBlockSection> singleSection(String title) {
      return <MarkdownNoteBlockSection>[
        MarkdownNoteBlockSection(title: title),
      ];
    }

    switch (kind) {
      case 'class':
        return BlockClassTemplate(
          name: name ?? 'ClassName',
          intro: intro,
        );
      case 'function':
        return BlockFunctionTemplate(
          signature: signature ?? name ?? 'void functionName()',
          intro: intro,
        );
      case 'variable':
        return BlockVariableTemplate(
          signature: signature ?? name ?? 'Type variableName',
          intro: intro,
        );
      case 'constructor':
        return BlockConstructorTemplate(
          signature: signature ?? name ?? 'ClassName()',
          intro: intro,
        );
      case 'notes':
        return BlockNotesTemplate(
          intro: intro,
          sections: singleSection('Notes'),
        );
      case 'warning':
        return BlockNotesTemplate(
          intro: intro,
          sections: singleSection('Warning'),
        );
      case 'examples':
        return BlockNotesTemplate(
          intro: intro,
          sections: singleSection('Examples'),
        );
      default:
        throw UnsupportedError('Unknown note block kind: $kind');
    }
  }
}
