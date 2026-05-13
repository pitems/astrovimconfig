import 'markdown_note_block.dart';
import 'note_block_template.dart';

class BlockClassTemplate extends NoteBlockTemplate {
  const BlockClassTemplate({
    required this.name,
    this.intro,
  });

  final String name;
  final String? intro;

  @override
  String render() {
    return renderMarkdownNoteBlock(
      title: name,
      headingLevel: 3,
      intro: intro,
      sections: const <MarkdownNoteBlockSection>[
        MarkdownNoteBlockSection(title: 'Notes'),
        MarkdownNoteBlockSection(title: 'Warning'),
        MarkdownNoteBlockSection(title: 'Examples'),
      ],
    );
  }
}
