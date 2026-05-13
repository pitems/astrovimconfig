import 'markdown_note_block.dart';
import 'note_block_template.dart';

class BlockVariableTemplate extends NoteBlockTemplate {
  const BlockVariableTemplate({
    required this.signature,
    this.intro,
  });

  final String signature;
  final String? intro;

  @override
  String render() {
    return renderMarkdownNoteBlock(
      title: signature,
      headingLevel: 5,
      intro: intro,
      sections: const <MarkdownNoteBlockSection>[
        MarkdownNoteBlockSection(title: 'Notes'),
        MarkdownNoteBlockSection(title: 'Warning'),
        MarkdownNoteBlockSection(title: 'Examples'),
      ],
    );
  }
}
