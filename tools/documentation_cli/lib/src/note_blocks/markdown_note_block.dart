class MarkdownNoteBlockSection {
  const MarkdownNoteBlockSection({
    required this.title,
    this.placeholder = '- ',
  });

  final String title;
  final String placeholder;
}

String renderMarkdownNoteBlock({
  required String title,
  required int headingLevel,
  required List<MarkdownNoteBlockSection> sections,
  String? intro,
}) {
  final buffer = StringBuffer();
  if (headingLevel > 0) {
    buffer.writeln('${'#' * headingLevel} $title');
    buffer.writeln();
  }

  if (intro != null && intro.trim().isNotEmpty) {
    buffer.writeln(intro.trimRight());
    buffer.writeln();
  }

  for (final section in sections) {
    buffer.writeln('**${section.title}**');
    buffer.writeln(section.placeholder);
    buffer.writeln();
  }

  return buffer.toString().trimRight();
}
