import 'markdown_note_block.dart';
import 'note_block_template.dart';

class BlockNotesTemplate extends NoteBlockTemplate {
  const BlockNotesTemplate({
    this.intro,
    this.sections = const <MarkdownNoteBlockSection>[
      MarkdownNoteBlockSection(title: 'Notes'),
      MarkdownNoteBlockSection(title: 'Warning'),
      MarkdownNoteBlockSection(title: 'Examples'),
    ],
  });

  final String? intro;
  final List<MarkdownNoteBlockSection> sections;

  @override
  String render() {
    return renderMarkdownNoteBlock(
      title: '',
      headingLevel: 0,
      intro: intro,
      sections: sections,
    );
  }
}
