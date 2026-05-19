abstract class ManualBodySanitizer {
  const ManualBodySanitizer();

  List<String> sanitize(List<String> bodyLines);
}

class BaseManualBodySanitizer extends ManualBodySanitizer {
  const BaseManualBodySanitizer();

  @override
  List<String> sanitize(List<String> bodyLines) {
    final filtered = <String>[];
    var skippingGeneratedBlock = false;
    var lastWasBlank = false;

    for (final line in bodyLines) {
      final trimmed = line.trim();

      if (trimmed == '---') {
        continue;
      }

      if (trimmed == '**Parameters**') {
        skippingGeneratedBlock = true;
        continue;
      }

      if (skippingGeneratedBlock) {
        if (trimmed.isEmpty || trimmed.startsWith('-') || trimmed.startsWith('>')) {
          continue;
        }

        skippingGeneratedBlock = false;
      }

      if (trimmed.startsWith('- Removed on `') || trimmed.startsWith('> Renamed from `')) {
        continue;
      }

      if (trimmed.isEmpty) {
        if (filtered.isEmpty || lastWasBlank) {
          continue;
        }
        filtered.add('');
        lastWasBlank = true;
        continue;
      }

      lastWasBlank = false;
      filtered.add(line.trimRight());
    }

    while (filtered.isNotEmpty && filtered.last.trim().isEmpty) {
      filtered.removeLast();
    }

    return filtered;
  }
}

class DartManualBodySanitizer extends BaseManualBodySanitizer {
  const DartManualBodySanitizer();
}

class TypeScriptManualBodySanitizer extends BaseManualBodySanitizer {
  const TypeScriptManualBodySanitizer();

  @override
  List<String> sanitize(List<String> bodyLines) {
    final generatedPrefixes = <String>[
      '- Extends:',
      '- Properties:',
      '- Methods:',
      '- Const enum:',
      '- Members:',
      '- Alias:',
      '- Type parameters:',
      '- Type:',
    ];

    final filtered = <String>[];
    var skippingGeneratedBlock = false;
    var lastWasBlank = false;

    for (final line in bodyLines) {
      final trimmed = line.trim();

      if (trimmed == '---') {
        continue;
      }

      if (trimmed == '**Parameters**') {
        skippingGeneratedBlock = true;
        continue;
      }

      if (generatedPrefixes.any(trimmed.startsWith)) {
        skippingGeneratedBlock = true;
        continue;
      }

      if (trimmed.startsWith('_Renamed from `') && trimmed.endsWith('_')) {
        continue;
      }

      if (skippingGeneratedBlock) {
        if (trimmed.isEmpty ||
            trimmed.startsWith('-') ||
            trimmed.startsWith('>') ||
            trimmed.startsWith('_Renamed from `')) {
          continue;
        }

        skippingGeneratedBlock = false;
      }

      if (trimmed.startsWith('- Removed on `') || trimmed.startsWith('> Renamed from `')) {
        continue;
      }

      if (trimmed.isEmpty) {
        if (filtered.isEmpty || lastWasBlank) {
          continue;
        }
        filtered.add('');
        lastWasBlank = true;
        continue;
      }

      lastWasBlank = false;
      filtered.add(line.trimRight());
    }

    while (filtered.isNotEmpty && filtered.last.trim().isEmpty) {
      filtered.removeLast();
    }

    return filtered;
  }
}
