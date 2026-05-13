import 'dart:convert';
import 'dart:io';
import '../lib/documentation_cli.dart';

Future<void> main(List<String> arguments) async {
  final app = CliApplication();
  final stdinText = await _readStdinIfAvailable();
  final exitCode = await app.run(
    arguments,
    stdinText: stdinText,
  );
  exit(exitCode);
}

Future<String?> _readStdinIfAvailable() async {
  if (stdin.hasTerminal) {
    return null;
  }

  final content = await stdin.transform(utf8.decoder).join();
  return content.isEmpty ? null : content;
}

