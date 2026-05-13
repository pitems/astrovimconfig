import 'dart:convert';
import 'dart:io';

import 'models/documentation_request.dart';
import 'models/documentation_result.dart';
import 'orchestrator/documentation_orchestrator.dart';
import 'note_blocks/note_block_registry.dart';
import 'renderers/markdown_document_renderer.dart';

class CliApplication {
  CliApplication({
    DocumentationOrchestrator? orchestrator,
    MarkdownDocumentRenderer? renderer,
  })  : orchestrator = orchestrator ?? DocumentationOrchestrator(),
        renderer = renderer ?? MarkdownDocumentRenderer(),
        noteBlockRegistry = const NoteBlockRegistry();

  final DocumentationOrchestrator orchestrator;
  final MarkdownDocumentRenderer renderer;
  final NoteBlockRegistry noteBlockRegistry;

  Future<int> run(
    List<String> arguments, {
    String? stdinText,
  }) async {
    // Keep the CLI behavior simple: help first, then command dispatch.
    if (arguments.isEmpty || arguments.first == 'help' || arguments.contains('--help')) {
      _printHelp();
      return 0;
    }

    final command = arguments.first;
    final parsed = _parseOptions(arguments.skip(1).toList());

    try {
      switch (command) {
        case 'analyze':
          return await _runAnalyze(parsed);
        case 'render':
          return await _runRender(parsed, stdinText: stdinText);
        case 'create':
          return await _runCreate(parsed);
        case 'blocks':
          return await _runBlocks(parsed);
        default:
          stderr.writeln('Unknown command: $command');
          _printHelp();
          return 64;
      }
    } on FormatException catch (error) {
      stderr.writeln(error.message);
      return 64;
    } on UnsupportedError catch (error) {
      stderr.writeln(error.message);
      return 65;
    } on FileSystemException catch (error) {
      stderr.writeln(
        'FileSystemException: ${error.message}'
        '${error.path != null ? ' path=${error.path}' : ''}'
        '${error.osError != null ? ' osError=${error.osError}' : ''}',
      );
      return 66;
    } catch (error) {
      stderr.writeln('Unhandled error: $error');
      return 1;
    }
  }

  Future<int> _runAnalyze(_ParsedOptions parsed) async {
    // Analyze only prints the normalized JSON contract.
    final request = _buildRequest(parsed);
    final result = await orchestrator.analyze(request);
    stdout.writeln(jsonEncode(result.toJson()));
    return 0;
  }

  Future<int> _runRender(
    _ParsedOptions parsed, {
    String? stdinText,
  }) async {
    // Render accepts either a JSON file or piped JSON from stdin.
    final jsonText = parsed.value('input') != null
        ? await File(parsed.value('input')!).readAsString()
        : stdinText;

    if (jsonText == null || jsonText.isEmpty) {
      throw const FormatException('render requires --input <file> or piped JSON on stdin');
    }

    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('render expected a JSON object');
    }

    final result = DocumentationResult.fromJson(decoded);
    final markdown = renderer.render(result);
    await _writeMaybe(parsed.value('output'), markdown);
    return 0;
  }

  Future<int> _runCreate(_ParsedOptions parsed) async {
    // Create is the main manual-test path: analyze source, then write markdown.
    final request = _buildRequest(parsed);
    final result = await orchestrator.analyze(request);
    final existingMarkdown = await _readExistingFile(request.docPath);
    final markdown = renderer.render(
      result,
      existingMarkdown: existingMarkdown,
    );
    await _writeMaybe(parsed.value('output') ?? request.docPath, markdown);
    return 0;
  }

  Future<int> _runBlocks(_ParsedOptions parsed) async {
    // Blocks emit reusable markdown snippets for human-authored documentation.
    final kind = parsed.required('kind');
    final template = noteBlockRegistry.create(
      kind: kind,
      name: parsed.value('name'),
      signature: parsed.value('signature'),
      intro: parsed.value('intro'),
    );
    await _writeMaybe(parsed.value('output') ?? '-', template.render());
    return 0;
  }

  DocumentationRequest _buildRequest(_ParsedOptions parsed) {
    final source = parsed.required('source');
    final fileType = parsed.required('filetype');
    final projectRoot = parsed.value('project-root');
    final docPath = _docPathForSource(
      source,
      projectRoot: projectRoot,
    );
    return DocumentationRequest(
      sourcePath: source,
      docPath: docPath,
      fileType: fileType,
      projectRoot: projectRoot,
      sourceText: parsed.value('source-text'),
      templateName: parsed.value('template'),
    );
  }

  String _docPathForSource(
    String sourcePath, {
    String? projectRoot,
  }) {
    final root = projectRoot ?? _guessProjectRoot(sourcePath);
    final normalizedSource = sourcePath.replaceAll('\\', '/');
    final normalizedRoot = root.replaceAll('\\', '/').replaceFirst(RegExp(r'/$'), '');
    final projectPrefix = '$normalizedRoot/';
    final libPrefix = '$normalizedRoot/lib/';

    String relative;
    if (normalizedSource.startsWith(libPrefix)) {
      relative = normalizedSource.substring(libPrefix.length);
    } else if (normalizedSource.startsWith(projectPrefix)) {
      relative = normalizedSource.substring(projectPrefix.length);
    } else {
      relative = normalizedSource.split('/').last;
    }

    relative = relative.replaceFirst(RegExp(r'\.[^.]+$'), '');
    return '$normalizedRoot/documentation/$relative.md';
  }

  String _guessProjectRoot(String sourcePath) {
    final normalized = sourcePath.replaceAll('\\', '/');
    final libIndex = normalized.lastIndexOf('/lib/');
    if (libIndex > 0) {
      return normalized.substring(0, libIndex);
    }

    final dir = File(sourcePath).parent;
    return dir.path;
  }

  Future<void> _writeMaybe(String? outputPath, String content) async {
    if (outputPath == null || outputPath.isEmpty || outputPath == '-') {
      // A dash means "print to stdout" for quick terminal inspection.
      stdout.write(content);
      return;
    }

    // Mirror docs into folders automatically instead of requiring manual setup.
    final target = File(outputPath);
    await target.parent.create(recursive: true);
    await target.writeAsString(content);
  }

  Future<String?> _readExistingFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  }

  void _printHelp() {
    stdout.writeln('Documentation CLI');
    stdout.writeln('');
    stdout.writeln('Usage:');
    stdout.writeln('  documentation_cli analyze --source <path> --doc-path <path> --filetype <type>');
    stdout.writeln('  documentation_cli render --input <json-file> [--output <path>]');
    stdout.writeln('  documentation_cli create --source <path> --doc-path <path> --filetype <type> [--output <path>]');
    stdout.writeln('  documentation_cli blocks --kind <class|function|variable|constructor|notes|warning|examples> [--name <text>] [--signature <text>]');
    stdout.writeln('');
    stdout.writeln('Options:');
    stdout.writeln('  --project-root <path>   Optional project root.');
    stdout.writeln('  --source-text <text>    Inline source content, mainly for tests.');
    stdout.writeln('  --template <name>       Template name for the generated doc.');
    stdout.writeln('  --intro <text>          Optional intro line for block templates.');
  }
}

class _ParsedOptions {
  _ParsedOptions(this.options);

  final Map<String, String?> options;

  String? value(String key) => options[key];

  String required(String key) {
    final value = options[key];
    if (value == null || value.isEmpty) {
      throw FormatException('Missing required option: --$key');
    }
    return value;
  }
}

_ParsedOptions _parseOptions(List<String> args) {
  final options = <String, String?>{};
  var index = 0;

  while (index < args.length) {
    final arg = args[index];
    if (!arg.startsWith('--')) {
      // Ignore bare positional extras so the parser stays forgiving.
      index += 1;
      continue;
    }

    final body = arg.substring(2);
    if (body.contains('=')) {
      final parts = body.split('=');
      options[parts.first] = parts.skip(1).join('=');
      index += 1;
      continue;
    }

    final next = index + 1 < args.length ? args[index + 1] : null;
    if (next != null && !next.startsWith('--')) {
      options[body] = next;
      index += 2;
    } else {
      options[body] = 'true';
      index += 1;
    }
  }

  return _ParsedOptions(options);
}
