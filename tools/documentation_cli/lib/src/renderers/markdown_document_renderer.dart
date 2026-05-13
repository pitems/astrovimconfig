import 'dart:io';

import '../models/documentation_parameter.dart';
import '../models/documentation_result.dart';
import '../models/documentation_symbol.dart';

class MarkdownDocumentRenderer {
  String render(
    DocumentationResult result, {
    String? existingMarkdown,
  }) {
    // Start from the previous markdown so manual notes can survive updates.
    final existing = _ExistingMarkdown.parse(existingMarkdown);
    final currentFunctions = result.symbols.where((symbol) => symbol.kind == 'function').toList();
    final currentVariables = result.symbols.where((symbol) => symbol.kind == 'variable').toList();
    final currentClasses = result.symbols.where((symbol) => symbol.kind == 'class').toList();
    final currentFunctionNames = currentFunctions.map((symbol) => symbol.name).toSet();
    final currentVariableNames = currentVariables.map((symbol) => symbol.name).toSet();

    final exactFunctionMatches = <String, _ExistingEntry>{};
    final exactVariableMatches = <String, _ExistingEntry>{};
    final exactClassMatches = <String, _ExistingEntry>{};
    final classRenameMatches = <String, _ExistingEntry>{};
    final classMemberRenameMatches = <String, _ExistingEntry>{};
    final handledClassMemberKeys = <String>{};

    for (final entry in existing.entries.where((entry) => entry.section == 'functions')) {
      if (currentFunctionNames.contains(entry.name)) {
        exactFunctionMatches[entry.name] = entry;
      }
    }

    for (final entry in existing.entries.where((entry) => entry.section == 'variables')) {
      if (currentVariableNames.contains(entry.name)) {
        exactVariableMatches[entry.name] = entry;
      }
    }

    final existingClassEntries = existing.entries
        .where(
          (entry) =>
              entry.section == 'classes' ||
              (entry.section == 'deprecated' && entry.className == null),
        )
        .toList();
    for (final classSymbol in currentClasses) {
      for (final entry in existingClassEntries) {
        if (entry.name == classSymbol.name) {
          exactClassMatches[classSymbol.name] = entry;
        }
      }
    }

    final existingClassMembersByClass = <String, List<_ExistingEntry>>{};
    for (final entry in existing.entries.where(
      (entry) => entry.section == 'class-member' || entry.section == 'deprecated',
    )) {
      final className = entry.className;
      if (className == null || className.isEmpty) {
        continue;
      }
      if (entry.section == 'deprecated' && entry.subgroup == null) {
        continue;
      }
      existingClassMembersByClass.putIfAbsent(className, () => <_ExistingEntry>[]).add(entry);
    }

    final classOwnerNames = <String, String>{};
    for (final classSymbol in currentClasses) {
      final renameCandidate = exactClassMatches.containsKey(classSymbol.name)
          ? null
          : _detectClassRename(
              classSymbol,
              existingClassEntries,
              existingClassMembersByClass,
              exactClassMatches.keys.toSet(),
            );

      if (renameCandidate != null) {
        classRenameMatches[classSymbol.name] = renameCandidate;
        classOwnerNames[classSymbol.name] = renameCandidate.name;
      } else {
        classOwnerNames[classSymbol.name] = classSymbol.name;
      }
    }

    for (final classSymbol in currentClasses) {
      final ownerName = classOwnerNames[classSymbol.name] ?? classSymbol.name;
      for (final group in const <String>['variables', 'constructors', 'functions']) {
        final currentMembers = classSymbol.children
            .where((member) => _classMemberGroup(member.kind) == group)
            .toList();
        if (currentMembers.isEmpty) {
          continue;
        }

        final existingMembers = existing.entries
            .where(
              (entry) =>
                  (entry.section == 'class-member' || entry.section == 'deprecated') &&
                  entry.className == ownerName &&
                  entry.subgroup == group,
            )
            .toList();
        final exactNames = currentMembers.map((member) => member.name).toSet();

        for (final entry in existingMembers) {
          if (exactNames.contains(entry.name)) {
            handledClassMemberKeys.add(_classMemberKey(entry.className ?? ownerName, group, entry.name));
          }
        }

        final renameMatches = _detectRenames(
          currentFunctions: currentMembers,
          existingEntries: existingMembers,
          exactFunctionNames: exactNames,
          minScore: 0.0,
        );

        if (renameMatches.isEmpty && currentMembers.length == existingMembers.length) {
          for (var i = 0; i < currentMembers.length; i++) {
            final currentMember = currentMembers[i];
            final existingMember = existingMembers[i];
            if (currentMember.name == existingMember.name) {
              continue;
            }
            renameMatches[currentMember.name] = existingMember;
          }
        }

        for (final pair in renameMatches.entries) {
          final key = _classMemberKey(classSymbol.name, group, pair.key);
          classMemberRenameMatches[key] = pair.value;
          handledClassMemberKeys.add(
            _classMemberKey(pair.value.className ?? ownerName, group, pair.value.name),
          );
        }
      }
    }

    final renameMatches = _detectRenames(
      currentFunctions: currentFunctions,
      existingEntries: existing.entries.where((entry) => entry.section == 'functions').toList(),
      exactFunctionNames: exactFunctionMatches.keys.toSet(),
    );

    final deprecatedEntries = <_ExistingEntry>[];
    final deprecatedSeen = <String>{};

    for (final entry in existing.entries.where((entry) => entry.section == 'deprecated')) {
      if (entry.className == null &&
          classRenameMatches.values.any((candidate) => candidate.name == entry.name)) {
        continue;
      }
      if (entry.className != null &&
          handledClassMemberKeys.contains(
            _classMemberKey(entry.className!, entry.subgroup ?? '', entry.name),
          )) {
        continue;
      }
      deprecatedEntries.add(entry);
      deprecatedSeen.add(_normalizeHeading(entry.heading));
    }

    final renamedOldNames = renameMatches.values.map((entry) => entry.name).toSet();

    for (final entry in existing.entries.where((entry) => entry.section == 'functions')) {
      if (exactFunctionMatches.containsKey(entry.name) || renamedOldNames.contains(entry.name)) {
        continue;
      }

      // Anything that disappeared from source becomes an archived entry.
      final normalized = _normalizeHeading(entry.heading);
      if (deprecatedSeen.contains(normalized)) {
        continue;
      }

      deprecatedEntries.add(
        _ExistingEntry(
          section: 'deprecated',
          heading: _ensureDeprecatedHeading(entry.heading),
          name: entry.name,
          bodyLines: entry.bodyLines,
          removedOn: entry.removedOn ?? _today(),
        ),
      );
      deprecatedSeen.add(normalized);
    }

    for (final entry in existing.entries.where((entry) => entry.section == 'class-member')) {
      final key = _classMemberKey(entry.className ?? '', entry.subgroup ?? '', entry.name);
      if (handledClassMemberKeys.contains(key)) {
        continue;
      }

      final normalized = _normalizeHeading(entry.heading);
      if (deprecatedSeen.contains(normalized)) {
        continue;
      }

      deprecatedEntries.add(
        _ExistingEntry(
          section: 'deprecated',
          heading: _ensureDeprecatedHeading(entry.heading),
          name: entry.name,
          bodyLines: entry.bodyLines,
          removedOn: entry.removedOn ?? _today(),
          className: entry.className,
          subgroup: entry.subgroup,
        ),
      );
      deprecatedSeen.add(normalized);
    }

    for (final entry in existing.entries.where((entry) => entry.section == 'classes')) {
      if (exactClassMatches.containsKey(entry.name) || classRenameMatches.values.contains(entry)) {
        continue;
      }

      final normalized = _normalizeHeading(entry.heading);
      if (deprecatedSeen.contains(normalized)) {
        continue;
      }

      deprecatedEntries.add(
        _ExistingEntry(
          section: 'deprecated',
          heading: _ensureDeprecatedHeading(entry.heading),
          name: entry.name,
          bodyLines: entry.bodyLines,
          removedOn: entry.removedOn ?? _today(),
        ),
      );
      deprecatedSeen.add(normalized);
    }

    final buffer = StringBuffer();
    final headings = result.template.headings;
    final sections = result.template.sectionOrder;

    buffer.writeln('# ${result.template.title}');
    buffer.writeln();

    for (final section in sections) {
      switch (section) {
        case 'overview':
          _renderOverview(buffer, result, headings['overview'] ?? 'Overview');
          break;
        case 'variables':
          if (currentVariables.isNotEmpty) {
            _renderVariables(
              buffer,
              headings['variables'] ?? 'Variables',
              currentVariables,
              exactVariableMatches,
            );
          }
          break;
        case 'classes':
          _renderClasses(
            buffer,
            headings['classes'] ?? 'Classes',
            currentClasses,
            existing,
            classRenameMatches,
            classOwnerNames,
            classMemberRenameMatches,
          );
          break;
        case 'functions':
          if (currentFunctions.isNotEmpty) {
            _renderFunctions(
              buffer,
              headings['functions'] ?? 'Functions',
              currentFunctions,
              exactFunctionMatches,
              renameMatches,
            );
          }
          break;
        case 'deprecated':
          _renderDeprecated(
            buffer,
            headings['deprecated'] ?? 'Deprecated',
            deprecatedEntries,
          );
          break;
        case 'dependencies':
          _renderDependencies(
            buffer,
            headings['dependencies'] ?? 'Dependencies',
            result.dependencies,
            result.references,
            result.projectRoot ?? _guessProjectRoot(result.sourcePath),
            result.sourcePath,
          );
          break;
        case 'notes':
          if (result.warnings.isEmpty) {
            break;
          }
          _renderNotes(
            buffer,
            headings['notes'] ?? 'Notes',
            result.warnings,
          );
          break;
        default:
          buffer.writeln('## ${_headingFor(section)}');
          buffer.writeln();
          buffer.writeln('_Section reserved by template._');
          buffer.writeln();
          break;
      }
    }

    return buffer.toString().trimRight();
  }

  void _renderOverview(
    StringBuffer buffer,
    DocumentationResult result,
    String heading,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();
    buffer.writeln('- Language: `${result.language}`');
    buffer.writeln('- Source: `${result.sourcePath}`');
    buffer.writeln('- Documentation: `${result.docPath}`');
    buffer.writeln('- Generated: `${result.metadata.generatedAt}`');
    buffer.writeln();
  }

  void _renderVariables(
    StringBuffer buffer,
    String heading,
    List<DocumentationSymbol> variables,
    Map<String, _ExistingEntry> existingVariables,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();

    if (variables.isEmpty) {
      buffer.writeln('_No entries detected yet._');
      buffer.writeln();
      return;
    }

    for (final variable in variables) {
      buffer.writeln(_symbolHeading(variable));
      _writeManualBody(
        buffer,
        existingVariables[variable.name]?.bodyLines,
      );
      buffer.writeln();
    }
  }

  void _renderSymbols(
    StringBuffer buffer,
    String heading,
    List<DocumentationSymbol> symbols,
    List<_ExistingEntry> existingEntries,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();

    if (symbols.isEmpty) {
      buffer.writeln('_No entries detected yet._');
      buffer.writeln();
      return;
    }

    final existingByName = {
      for (final entry in existingEntries) entry.name: entry,
    };

    for (final symbol in symbols) {
      buffer.writeln(_symbolHeading(symbol));
      _writeManualBody(
        buffer,
        existingByName[symbol.name]?.bodyLines,
      );
      buffer.writeln();
    }
  }

  void _renderClasses(
    StringBuffer buffer,
    String heading,
    List<DocumentationSymbol> classes,
    _ExistingMarkdown existing,
    Map<String, _ExistingEntry> classRenameMatches,
    Map<String, String> classOwnerNames,
    Map<String, _ExistingEntry> classMemberRenameMatches,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();

    if (classes.isEmpty) {
      buffer.writeln('_No entries detected yet._');
      buffer.writeln();
      return;
    }

    for (var index = 0; index < classes.length; index++) {
      final classSymbol = classes[index];
      _renderClassTree(
        buffer,
        classSymbol,
        level: 3,
        existing: existing,
        classRenameMatches: classRenameMatches,
        classOwnerNames: classOwnerNames,
        classMemberRenameMatches: classMemberRenameMatches,
      );
      if (index < classes.length - 1) {
        buffer.writeln('---');
        buffer.writeln();
      } else {
        buffer.writeln();
      }
    }
  }

  void _renderClassTree(
    StringBuffer buffer,
    DocumentationSymbol classSymbol, {
    required int level,
    required _ExistingMarkdown existing,
    required Map<String, _ExistingEntry> classRenameMatches,
    required Map<String, String> classOwnerNames,
    required Map<String, _ExistingEntry> classMemberRenameMatches,
  }) {
    buffer.writeln('${'#' * level} ${_symbolLabel(classSymbol)}');
    final renameSource = classRenameMatches[classSymbol.name];
    final ownerName = classOwnerNames[classSymbol.name] ?? classSymbol.name;
    if (renameSource != null) {
      _writeRenameNote(buffer, renameSource.name);
      buffer.writeln();
    }
    final existingClassEntry = existing.classEntry(ownerName) ?? renameSource;
    _writeManualBody(buffer, existingClassEntry?.bodyLines);
    buffer.writeln();

    final fields = classSymbol.children.where((symbol) => symbol.kind == 'field').toList();
    final constructors = classSymbol.children.where((symbol) => symbol.kind == 'constructor').toList();
    final methods = classSymbol.children
        .where((symbol) => symbol.kind == 'function' || symbol.kind == 'getter' || symbol.kind == 'setter')
        .toList();
    final innerClasses = classSymbol.children.where((symbol) => symbol.kind == 'class').toList();

    _renderClassMemberGroup(
      buffer,
      level + 1,
      'Variables',
      classSymbol.name,
      ownerName,
      'variables',
      fields,
      existing,
      classMemberRenameMatches,
    );
    _renderClassMemberGroup(
      buffer,
      level + 1,
      'Constructors',
      classSymbol.name,
      ownerName,
      'constructors',
      constructors,
      existing,
      classMemberRenameMatches,
    );
    _renderClassMemberGroup(
      buffer,
      level + 1,
      'Functions',
      classSymbol.name,
      ownerName,
      'functions',
      methods,
      existing,
      classMemberRenameMatches,
    );

    for (final innerClass in innerClasses) {
      _renderClassTree(
        buffer,
        innerClass,
        level: level + 1,
        existing: existing,
        classRenameMatches: classRenameMatches,
        classOwnerNames: classOwnerNames,
        classMemberRenameMatches: classMemberRenameMatches,
      );
    }
  }

  bool _isClassRenderableMember(DocumentationSymbol symbol) {
    return symbol.kind == 'field' ||
        symbol.kind == 'constructor' ||
        symbol.kind == 'function' ||
        symbol.kind == 'getter' ||
        symbol.kind == 'setter';
  }

  _ExistingEntry? _detectClassRename(
    DocumentationSymbol currentClass,
    List<_ExistingEntry> existingClasses,
    Map<String, List<_ExistingEntry>> existingClassMembersByClass,
    Set<String> exactClassNames,
  ) {
    final candidates = existingClasses
        .where((entry) => !exactClassNames.contains(entry.name))
        .toList();
    if (candidates.isEmpty) {
      return null;
    }

    _ExistingEntry? best;
    var bestScore = 0.0;

    for (final candidate in candidates) {
      final score = _classSimilarity(
        currentClass,
        candidate,
        existingClassMembersByClass[candidate.name] ?? const <_ExistingEntry>[],
      );
      if (score > bestScore && score >= 0.45) {
        best = candidate;
        bestScore = score;
      }
    }

    return best;
  }

  double _classSimilarity(
    DocumentationSymbol currentClass,
    _ExistingEntry candidate,
    List<_ExistingEntry> existingClassMembers,
  ) {
    final currentFields = <String>{};
    final currentFunctions = <String>{};
    var currentConstructors = 0;
    for (final member in currentClass.children) {
      final group = _classMemberGroup(member.kind);
      if (group == 'variables') {
        currentFields.add(_fieldSignatureKeyFromSymbol(member));
      } else if (group == 'functions') {
        currentFunctions.add(_memberStructuralKeyFromSymbol(member));
      } else if (group == 'constructors') {
        currentConstructors += 1;
      }
    }

    final existingFields = <String>{};
    final existingFunctions = <String>{};
    var existingConstructors = 0;
    for (final entry in existingClassMembers) {
      final group = entry.subgroup ?? '';
      if (group == 'variables') {
        existingFields.add(_fieldSignatureKeyFromHeading(entry.heading));
      } else if (group == 'functions') {
        existingFunctions.add(_memberStructuralKeyFromHeading(entry.heading));
      } else if (group == 'constructors') {
        existingConstructors += 1;
      }
    }

    final fieldWeight = _groupWeight(currentFields.length, existingFields.length);
    final functionWeight = _groupWeight(currentFunctions.length, existingFunctions.length);
    final constructorWeight = _groupWeight(currentConstructors, existingConstructors);

    var weightedScore = 0.0;
    var totalWeight = 0.0;

    if (fieldWeight > 0) {
      weightedScore += _setSimilarity(currentFields, existingFields) * fieldWeight;
      totalWeight += fieldWeight;
    }
    if (functionWeight > 0) {
      weightedScore += _setSimilarity(currentFunctions, existingFunctions) * functionWeight;
      totalWeight += functionWeight;
    }
    if (constructorWeight > 0) {
      weightedScore += _countSimilarity(currentConstructors, existingConstructors) * constructorWeight;
      totalWeight += constructorWeight;
    }

    final nameScore = _nameSimilarity(currentClass.name, candidate.name);
    if (totalWeight == 0) {
      return nameScore;
    }
    final structuralScore = weightedScore / totalWeight;
    return (structuralScore * 0.85) + (nameScore * 0.15);
  }

  double _groupWeight(int currentCount, int existingCount) {
    final weight = currentCount > existingCount ? currentCount : existingCount;
    return weight.toDouble();
  }

  double _setSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) {
      return 1.0;
    }
    if (a.isEmpty || b.isEmpty) {
      return 0.0;
    }

    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    if (union == 0) {
      return 1.0;
    }
    return intersection / union;
  }

  double _countSimilarity(int a, int b) {
    if (a == 0 && b == 0) {
      return 1.0;
    }
    final maxCount = a > b ? a : b;
    if (maxCount == 0) {
      return 1.0;
    }
    final minCount = a < b ? a : b;
    return minCount / maxCount;
  }

  String _memberStructuralKeyFromSymbol(DocumentationSymbol symbol) {
    if (symbol.kind == 'getter' || symbol.kind == 'setter' || symbol.kind == 'function') {
      return _signatureKeyFromSymbol(symbol);
    }
    return _fieldSignatureKeyFromSymbol(symbol);
  }

  String _memberStructuralKeyFromHeading(String heading) {
    final normalized = heading.trim();

    final getterMatch = RegExp(r'^#+\s+(?:(.+?)\s+)?get\s+[A-Za-z_]\w*$').firstMatch(normalized);
    if (getterMatch != null) {
      final returnType = _normalizeType(getterMatch.group(1) ?? 'void');
      return '$returnType::';
    }

    final setterMatch = RegExp(r'^#+\s+(?:(.+?)\s+)?set\s+[A-Za-z_]\w*\((.*)\)$').firstMatch(normalized);
    if (setterMatch != null) {
      final returnType = _normalizeType(setterMatch.group(1) ?? 'void');
      final parameters = _splitParameters(setterMatch.group(2) ?? '');
      final named = normalized.contains('{') || normalized.contains('}');
      final canonicalParameters = parameters
          .map((text) => _canonicalParameterFromText(text, named: named))
          .join('|');
      return '$returnType::$canonicalParameters';
    }

    final parsed = _parseHeading(normalized);
    if (parsed != null) {
      final named = normalized.contains('{') || normalized.contains('}');
      final parameters = parsed.parameters
          .map((text) => _canonicalParameterFromText(text, named: named))
          .join('|');
      return '${_normalizeType(parsed.returnType)}::$parameters';
    }

    return _fieldSignatureKeyFromHeading(normalized);
  }

  String _classMemberGroup(String kind) {
    switch (kind) {
      case 'field':
        return 'variables';
      case 'constructor':
        return 'constructors';
      case 'getter':
      case 'setter':
      case 'function':
        return 'functions';
      default:
        return kind;
    }
  }

  String _classMemberKey(String className, String group, String name) {
    return '$className::$group::$name';
  }

  void _renderClassMemberGroup(
    StringBuffer buffer,
    int headingLevel,
    String heading,
    String currentClassName,
    String ownerName,
    String group,
    List<DocumentationSymbol> members,
    _ExistingMarkdown existing,
    Map<String, _ExistingEntry> classMemberRenameMatches,
  ) {
    if (members.isEmpty) {
      return;
    }

    buffer.writeln('${'#' * headingLevel} $heading');
    buffer.writeln();
    for (final member in members) {
      final key = _classMemberKey(currentClassName, group, member.name);
      final existingEntry = existing.classMemberEntry(
        ownerName,
        group,
        member.name,
      ) ?? classMemberRenameMatches[key];
      buffer.writeln('${'#' * (headingLevel + 1)} ${_symbolLabel(member)}');
      final renameSource = classMemberRenameMatches[key];
      if (renameSource != null) {
        _writeRenameNote(buffer, renameSource.name);
        buffer.writeln();
      }
      _writeManualBody(buffer, existingEntry?.bodyLines);
      buffer.writeln();
    }
  }

  void _renderFunctions(
    StringBuffer buffer,
    String heading,
    List<DocumentationSymbol> functions,
    Map<String, _ExistingEntry> existingFunctions,
    Map<String, _ExistingEntry> renameMatches,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();

    if (functions.isEmpty) {
      buffer.writeln('_No entries detected yet._');
      buffer.writeln();
      return;
    }

    for (final function in functions) {
      final renameSource = renameMatches[function.name];
      final bodySource = renameSource ?? existingFunctions[function.name];

      // Emit the fresh signature first, then layer any preserved notes below it.
      buffer.writeln(_symbolHeading(function));
      if (renameSource != null) {
        _writeRenameNote(buffer, renameSource.name);
        buffer.writeln();
      }

      _writeParameters(function.parameters, buffer);
      _writeManualBody(buffer, bodySource?.bodyLines);
      buffer.writeln();
    }
  }

  void _renderDeprecated(
    StringBuffer buffer,
    String heading,
    List<_ExistingEntry> entries,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();

    if (entries.isEmpty) {
      buffer.writeln('_No deprecated entries yet._');
      buffer.writeln();
      return;
    }

    for (final entry in entries) {
      // Deprecated entries stay visible so the doc keeps a memory of old symbols.
      buffer.writeln(_deprecatedDisplayHeading(entry));
      if (entry.removedOn != null && entry.removedOn!.isNotEmpty) {
        buffer.writeln('- Removed on `${entry.removedOn}`');
      }
      _writeManualBody(buffer, entry.bodyLines);
      buffer.writeln();
    }
  }

  void _renderDependencies(
    StringBuffer buffer,
    String heading,
    List<Map<String, dynamic>> dependencies,
    List<DocumentationReference> references,
    String projectRoot,
    String sourcePath,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();

    final internalDependencies = <_DependencyLink>[];

    for (final reference in references) {
      final resolved = _resolveReference(reference, sourcePath);
      if (resolved == null) {
        continue;
      }
      if (!_isInsideProject(resolved.sourcePath, projectRoot)) {
        continue;
      }

      // Create placeholder docs so dependency links always have a target.
      _ensurePlaceholderDoc(
        resolved.docPath,
        resolved.title,
        resolved.sourcePath,
      );

      internalDependencies.add(
        _DependencyLink(
          name: resolved.name,
          docPath: resolved.docPath,
          exists: resolved.exists,
        ),
      );
    }

    if (internalDependencies.isEmpty && dependencies.isEmpty) {
      buffer.writeln('_No internal dependencies detected yet._');
      buffer.writeln();
      return;
    }

    for (final dependency in internalDependencies) {
      // These links become the navigation layer for the documentation graph.
      final link = dependency.exists
          ? dependency.docPath
          : dependency.docPath;
      buffer.writeln('- [${dependency.name}]($link)');
    }

    if (internalDependencies.isNotEmpty) {
      buffer.writeln();
    }
    buffer.writeln();
  }

  void _renderNotes(
    StringBuffer buffer,
    String heading,
    List<String> warnings,
  ) {
    buffer.writeln('## $heading');
    buffer.writeln();

    if (warnings.isEmpty) {
      buffer.writeln('_No notes yet._');
      buffer.writeln();
      return;
    }

    for (final warning in warnings) {
      buffer.writeln('- $warning');
    }
    buffer.writeln();
  }

  void _writeParameters(
    List<DocumentationParameter> parameters,
    StringBuffer buffer,
  ) {
    if (parameters.isEmpty) {
      return;
    }

    buffer.writeln('**Parameters**');
    for (final parameter in parameters) {
      // Use a placeholder instead of repeating the signature verbatim.
      final type = parameter.type == null || parameter.type!.isEmpty
          ? '----'
          : parameter.type!;
      final defaultValue = parameter.defaultValue;
      final typeLabel = defaultValue == null || defaultValue.isEmpty
          ? type
          : '$type, default: $defaultValue';
      buffer.writeln('- `${parameter.name}` ($typeLabel): ----');
    }
    buffer.writeln();
  }

  void _writeManualBody(
    StringBuffer buffer,
    List<String>? bodyLines,
  ) {
    if (bodyLines == null || bodyLines.isEmpty) {
      return;
    }

    final filtered = _sanitizeManualBody(bodyLines);

    if (filtered.isEmpty) {
      return;
    }

    // Strip generated metadata and keep only human-authored notes.
    for (final line in filtered) {
      buffer.writeln(line);
    }
  }

  void _writeRenameNote(
    StringBuffer buffer,
    String originalName,
  ) {
    buffer.writeln('_Renamed from `$originalName`_');
  }

  List<String> _sanitizeManualBody(List<String> bodyLines) {
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

  Map<String, _ExistingEntry> _detectRenames({
    required List<DocumentationSymbol> currentFunctions,
    required List<_ExistingEntry> existingEntries,
    required Set<String> exactFunctionNames,
    double minScore = 0.35,
  }) {
    final currentCandidates = currentFunctions
        .where((function) => !exactFunctionNames.contains(function.name))
        .toList();
    final existingCandidates = existingEntries
        .where((entry) => !exactFunctionNames.contains(entry.name))
        .toList();

    final result = <String, _ExistingEntry>{};
    final usedExisting = <String>{};

    // Pair renamed functions by normalized signature first, then by name similarity.
    final groupedCurrent = <String, List<DocumentationSymbol>>{};
    final groupedExisting = <String, List<_ExistingEntry>>{};

    for (final function in currentCandidates) {
      groupedCurrent.putIfAbsent(
        _signatureKeyFromSymbol(function),
        () => <DocumentationSymbol>[],
      ).add(function);
    }

    for (final entry in existingCandidates) {
      groupedExisting.putIfAbsent(
        _signatureKeyFromHeading(entry.heading),
        () => <_ExistingEntry>[],
      ).add(entry);
    }

    final keys = <String>{
      ...groupedCurrent.keys,
      ...groupedExisting.keys,
    };

    for (final key in keys) {
      final currentList = groupedCurrent[key] ?? const <DocumentationSymbol>[];
      final existingList = groupedExisting[key] ?? const <_ExistingEntry>[];
      if (currentList.isEmpty || existingList.isEmpty) {
        continue;
      }

      final pairs = <_RenameCandidate>[];
      for (final current in currentList) {
        for (final existing in existingList) {
          if (usedExisting.contains(existing.name)) {
            continue;
          }
          final score = _nameSimilarity(current.name, existing.name);
          if (score >= minScore) {
            pairs.add(
              _RenameCandidate(
                currentName: current.name,
                existing: existing,
                score: score,
              ),
            );
          }
        }
      }

      pairs.sort((a, b) => b.score.compareTo(a.score));

      for (final pair in pairs) {
        if (result.containsKey(pair.currentName) || usedExisting.contains(pair.existing.name)) {
          continue;
        }
        result[pair.currentName] = pair.existing;
        usedExisting.add(pair.existing.name);
      }
    }

    return result;
  }

  String _symbolHeading(DocumentationSymbol symbol) {
    return '### ${_symbolLabel(symbol)}';
  }

  String _symbolLabel(DocumentationSymbol symbol) {
    if (symbol.signature != null && symbol.signature!.isNotEmpty) {
      return symbol.signature!;
    }

    final parts = <String>[symbol.name];
    if (symbol.kind == 'field') {
      final modifiers = <String>[];
      final metadata = symbol.metadata;
      if (metadata['isLate'] == true) {
        modifiers.add('late');
      }
      if (metadata['isFinal'] == true) {
        modifiers.add('final');
      } else if (metadata['isConst'] == true) {
        modifiers.add('const');
      } else if (metadata['isStatic'] == true) {
        modifiers.add('static');
      }
      if (symbol.typeAnnotation != null && symbol.typeAnnotation!.isNotEmpty) {
        modifiers.add(symbol.typeAnnotation!);
      }
      if (modifiers.isNotEmpty) {
        return [...modifiers, symbol.name].join(' ');
      }
    }

    if (symbol.returnType != null && symbol.returnType!.isNotEmpty) {
      parts.insert(0, symbol.returnType!);
    } else if (symbol.typeAnnotation != null && symbol.typeAnnotation!.isNotEmpty) {
      parts.insert(0, symbol.typeAnnotation!);
    }

    return parts.join(' ');
  }

  String _headingFor(String section) {
    return section[0].toUpperCase() + section.substring(1);
  }

  String _signatureKeyFromSymbol(DocumentationSymbol symbol) {
    if (symbol.kind == 'field') {
      return 'field::${_fieldSignatureKeyFromSymbol(symbol)}';
    }

    final returnType = _normalizeType(symbol.returnType ?? symbol.typeAnnotation ?? 'void');
    final parameters = symbol.parameters.map(_canonicalParameterFromModel).join('|');
    return '$returnType::$parameters';
  }

  String _signatureKeyFromHeading(String heading) {
    return _memberStructuralKeyFromHeading(heading);
  }

  String _canonicalParameterFromModel(DocumentationParameter parameter) {
    final type = _normalizeType(parameter.type ?? '');
    final mode = parameter.isNamed ? 'named' : 'positional';
    final required = parameter.isRequired ? 'required' : 'optional';
    final defaultValue = (parameter.defaultValue ?? '').trim();
    return '$mode:$required:$type:$defaultValue';
  }

  String _canonicalParameterFromText(String text, {required bool named}) {
    final cleaned = text
        .replaceAll(RegExp(r'^\{'), '')
        .replaceAll(RegExp(r'\}$'), '')
        .replaceAll(RegExp(r'\s*=\s*.*$'), '')
        .trim();
    if (cleaned.isEmpty) {
      return '';
    }

    final pieces = cleaned.split(RegExp(r'\s+'));
    final required = pieces.contains('required');
    final filtered = pieces
        .where((piece) => piece != 'required' && piece != 'this' && piece != 'final' && piece != 'covariant')
        .toList();
    if (filtered.isEmpty) {
      return '';
    }

    final type = filtered.length == 1 ? filtered.first : filtered.sublist(0, filtered.length - 1).join(' ');
    final normalizedType = _normalizeType(type);
    final mode = named ? 'named' : 'positional';
    return '$mode:${required ? 'required' : 'optional'}:$normalizedType:';
  }

  String _fieldSignatureKeyFromSymbol(DocumentationSymbol symbol) {
    final parts = <String>[];
    final metadata = symbol.metadata;
    if (metadata['isLate'] == true) {
      parts.add('late');
    }
    if (metadata['isConst'] == true) {
      parts.add('const');
    } else if (metadata['isFinal'] == true) {
      parts.add('final');
    }
    if (metadata['isStatic'] == true) {
      parts.add('static');
    }
    if (symbol.typeAnnotation != null && symbol.typeAnnotation!.isNotEmpty) {
      parts.add(_normalizeType(symbol.typeAnnotation!));
    }
    return parts.join('|');
  }

  String _fieldSignatureKeyFromHeading(String heading) {
    final cleaned = heading.replaceFirst(RegExp(r'^#+\s+'), '').trim();
    if (cleaned.isEmpty) {
      return heading;
    }

    final tokens = cleaned.split(RegExp(r'\s+'));
    if (tokens.isEmpty) {
      return cleaned;
    }

    final beforeName = tokens.sublist(0, tokens.length - 1);
    final parts = <String>[];
    if (beforeName.contains('late')) {
      parts.add('late');
    }
    if (beforeName.contains('const')) {
      parts.add('const');
    } else if (beforeName.contains('final')) {
      parts.add('final');
    }
    if (beforeName.contains('static')) {
      parts.add('static');
    }
    if (beforeName.isNotEmpty) {
      parts.add(_normalizeType(beforeName.where((token) => token != 'late' && token != 'const' && token != 'final' && token != 'static').join(' ')));
    }
    return parts.join('|');
  }

  String _normalizeType(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _ensureDeprecatedHeading(String heading) {
    final normalized = _normalizeHeading(heading);
    if (normalized.endsWith('⚠️ Deprecated')) {
      return normalized;
    }
    return '$normalized ⚠️ Deprecated';
  }

  String _deprecatedDisplayHeading(_ExistingEntry entry) {
    if (entry.className == null || entry.className!.isEmpty) {
      return _ensureDeprecatedHeading(entry.heading);
    }

    final normalized = _normalizeHeading(entry.heading).replaceFirst(RegExp(r'^#+\s+'), '');
    return '### ${entry.className}: $normalized ⚠️ Deprecated';
  }

  String _normalizeHeading(String heading) {
    return heading.replaceFirst(RegExp(r'\s+⚠️ Deprecated$'), '');
  }

  _ParsedHeading? _parseHeading(String heading) {
    final match = RegExp(r'^#+\s+(.+?)\s+([A-Za-z_]\w*)\((.*)\)$').firstMatch(heading.trim());
    if (match == null) {
      return null;
    }

    return _ParsedHeading(
      returnType: match.group(1)!.trim(),
      name: match.group(2)!.trim(),
      parameters: _splitParameters(match.group(3)!),
    );
  }

  List<String> _splitParameters(String parameters) {
    final text = parameters.trim();
    if (text.isEmpty) {
      return const <String>[];
    }

    final out = <String>[];
    final buffer = StringBuffer();
    var depth = 0;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == ',' && depth == 0) {
        out.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }
      if (char == '(' || char == '[' || char == '{' || char == '<') {
        depth += 1;
      } else if (char == ')' || char == ']' || char == '}' || char == '>') {
        if (depth > 0) {
          depth -= 1;
        }
      }
      buffer.write(char);
    }

    final last = buffer.toString().trim();
    if (last.isNotEmpty) {
      out.add(last);
    }
    return out;
  }

  double _nameSimilarity(String a, String b) {
    if (a == b) {
      return 1.0;
    }

    final distance = _levenshtein(a.toLowerCase(), b.toLowerCase());
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) {
      return 1.0;
    }
    return 1.0 - (distance / maxLen);
  }

  int _levenshtein(String a, String b) {
    if (a == b) {
      return 0;
    }
    if (a.isEmpty) {
      return b.length;
    }
    if (b.isEmpty) {
      return a.length;
    }

    final rows = List.generate(a.length + 1, (_) => List<int>.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      rows[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      rows[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        rows[i][j] = [
          rows[i - 1][j] + 1,
          rows[i][j - 1] + 1,
          rows[i - 1][j - 1] + cost,
        ].reduce((min, value) => value < min ? value : min);
      }
    }

    return rows[a.length][b.length];
  }

  String _today() {
    final now = DateTime.now().toUtc();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  _ResolvedReference? _resolveReference(DocumentationReference reference, String sourcePath) {
    if (!reference.exists && reference.docPath.isNotEmpty) {
      return _ResolvedReference(
        name: reference.name,
        sourcePath: reference.sourcePath.isNotEmpty ? reference.sourcePath : sourcePath,
        docPath: reference.docPath,
        exists: false,
        title: 'Documentation: ${reference.name}',
      );
    }

    final resolvedDocPath = reference.docPath.isNotEmpty
        ? reference.docPath
        : _docPathForInternalReference(reference.sourcePath, sourcePath);

    return _ResolvedReference(
      name: reference.name,
      sourcePath: reference.sourcePath.isNotEmpty ? reference.sourcePath : sourcePath,
      docPath: resolvedDocPath,
      exists: File(resolvedDocPath).existsSync(),
      title: 'Documentation: ${reference.name}',
    );
  }

  void _ensurePlaceholderDoc(
    String docPath,
    String title,
    String sourcePath,
  ) {
    final file = File(docPath);
    if (file.existsSync()) {
      return;
    }

    // Create a small stub so the navigation graph stays intact before full docs exist.
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      [
        '# $title',
        '',
        '## Overview',
        '',
        '- Status: `Pending documentation`',
        '- Source: `$sourcePath`',
        '',
        '## Notes',
        '',
        '_This file will be populated when the target source is documented._',
      ].join('\n'),
    );
  }

  String _docPathForInternalReference(String uriValue, String sourcePath) {
    // Mirror the source tree under documentation/ to keep links predictable.
    final cleaned = uriValue
        .replaceFirst(RegExp(r'^package:[^/]+/'), '')
        .replaceFirst(RegExp(r'^\.\/'), '')
        .replaceFirst(RegExp(r'^\.\.\/'), '')
        .replaceFirst(RegExp(r'^lib\/'), '');

    final relative = cleaned.replaceFirst(RegExp(r'\.[^.]+$'), '');
    final docRelative = relative.replaceFirst(RegExp(r'^lib\/'), '');
    final root = _guessProjectRoot(sourcePath);
    return '$root/documentation/$docRelative.md';
  }

  bool _isInsideProject(String path, String projectRoot) {
    return path.startsWith(projectRoot);
  }

  String _guessProjectRoot(String sourcePath) {
    final normalized = sourcePath.replaceAll('\\', '/');
    final libIndex = normalized.lastIndexOf('/lib/');
    if (libIndex > 0) {
      return normalized.substring(0, libIndex);
    }
    return File(sourcePath).parent.path;
  }
}

class _ResolvedReference {
  const _ResolvedReference({
    required this.name,
    required this.sourcePath,
    required this.docPath,
    required this.exists,
    required this.title,
  });

  final String name;
  final String sourcePath;
  final String docPath;
  final bool exists;
  final String title;
}

class _ExistingMarkdown {
  const _ExistingMarkdown({required this.entries});

  final List<_ExistingEntry> entries;

  const _ExistingMarkdown.empty() : entries = const <_ExistingEntry>[];

  factory _ExistingMarkdown.parse(String? markdown) {
    if (markdown == null || markdown.isEmpty) {
      return const _ExistingMarkdown(entries: <_ExistingEntry>[]);
    }

    final lines = markdown.split('\n');
    final entries = <_ExistingEntry>[];
    String? currentSection;
    String? currentClassName;
    String? currentClassGroup;
    _ExistingEntry? currentEntry;
    final body = <String>[];

    void flush() {
      if (currentEntry == null) {
        return;
      }
      entries.add(
        _ExistingEntry(
          section: currentEntry!.section,
          heading: currentEntry!.heading,
          name: currentEntry!.name,
          bodyLines: List<String>.from(body),
          removedOn: currentEntry!.removedOn,
          className: currentEntry!.className,
          subgroup: currentEntry!.subgroup,
        ),
      );
      body.clear();
      currentEntry = null;
    }

    for (final line in lines) {
      if (line.startsWith('## ')) {
        flush();
        currentSection = _sectionKeyFromHeading(line.substring(3).trim());
        currentClassName = null;
        currentClassGroup = null;
        continue;
      }

      if (currentSection == 'classes' && line.startsWith('### ')) {
        flush();
        currentEntry = _ExistingEntry(
          section: 'classes',
          heading: line.trim(),
          name: _extractNameFromHeading(line.trim()),
          bodyLines: const <String>[],
          removedOn: null,
        );
        currentClassName = _extractClassName(line.trim());
        currentClassGroup = null;
        continue;
      }

      if (line.startsWith('### ') &&
          (currentSection == 'functions' ||
              currentSection == 'variables' ||
              currentSection == 'deprecated')) {
        flush();
        currentEntry = _ExistingEntry(
          section: currentSection!,
          heading: line.trim(),
          name: _extractNameFromHeading(line.trim()),
          bodyLines: const <String>[],
          removedOn: null,
        );
        continue;
      }

      if (currentSection == 'classes' && line.startsWith('#### ')) {
        flush();
        currentClassGroup = _classGroupKey(line.substring(5).trim());
        continue;
      }

      if (currentSection == 'classes' &&
          currentClassName != null &&
          currentClassGroup != null &&
          line.startsWith('##### ')) {
        flush();
        currentEntry = _ExistingEntry(
          section: 'class-member',
          heading: line.trim(),
          name: _extractNameFromHeading(line.trim()),
          bodyLines: const <String>[],
          removedOn: null,
          className: currentClassName,
          subgroup: currentClassGroup,
        );
        continue;
      }

      if (currentEntry != null) {
        body.add(line);
      }
    }

    flush();

    final normalizedEntries = entries.map((entry) {
      if (entry.section != 'deprecated') {
        return entry;
      }
      final removedOn = entry.removedOn ?? _extractRemovedOn(entry.bodyLines);
      return _ExistingEntry(
        section: entry.section,
        heading: entry.heading,
        name: entry.name,
        bodyLines: entry.bodyLines,
        removedOn: removedOn,
        className: entry.className,
        subgroup: entry.subgroup,
      );
    }).toList();

    return _ExistingMarkdown(entries: normalizedEntries);
  }

  static String _sectionKeyFromHeading(String heading) {
    final lower = heading.toLowerCase();
    if (lower.startsWith('overview')) {
      return 'overview';
    }
    if (lower.startsWith('variables')) {
      return 'variables';
    }
    if (lower.startsWith('functions')) {
      return 'functions';
    }
    if (lower.startsWith('deprecated')) {
      return 'deprecated';
    }
    if (lower.startsWith('classes')) {
      return 'classes';
    }
    if (lower.startsWith('dependencies')) {
      return 'dependencies';
    }
    if (lower.startsWith('notes')) {
      return 'notes';
    }
    return heading.toLowerCase();
  }

  static String _extractNameFromHeading(String heading) {
    final normalized = heading.replaceFirst(RegExp(r'\s+⚠️ Deprecated$'), '');
    final functionMatch = RegExp(r'^#+\s+.*?\b([A-Za-z_]\w*)\s*\(').firstMatch(normalized);
    if (functionMatch != null) {
      return functionMatch.group(1)!;
    }

    final variableMatch = RegExp(r'^#+\s+.*?\b([A-Za-z_]\w*)\s*$').firstMatch(normalized);
    if (variableMatch != null) {
      return variableMatch.group(1)!;
    }

    return normalized;
  }

  static String _extractClassName(String heading) {
    return heading.replaceFirst(RegExp(r'^###\s+'), '').trim();
  }

  static String _classGroupKey(String heading) {
    final lower = heading.toLowerCase();
    if (lower.startsWith('variables')) {
      return 'variables';
    }
    if (lower.startsWith('constructors')) {
      return 'constructors';
    }
    if (lower.startsWith('functions')) {
      return 'functions';
    }
    return lower;
  }

  _ExistingEntry? classMemberEntry(String className, String group, String name) {
    for (final entry in entries) {
      if ((entry.section == 'class-member' || entry.section == 'deprecated') &&
          entry.className == className &&
          entry.subgroup == group &&
          entry.name == name) {
        return entry;
      }
    }
    return null;
  }

  _ExistingEntry? classEntry(String className) {
    for (final entry in entries) {
      if ((entry.section == 'classes' || entry.section == 'deprecated') &&
          entry.className == null &&
          entry.name == className) {
        return entry;
      }
    }
    return null;
  }

  static String? _extractRemovedOn(List<String> bodyLines) {
    for (final line in bodyLines) {
      final match = RegExp(r'^\s*-\s*Removed on `([^`]+)`\s*$').firstMatch(line.trim());
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }
}

class _ExistingEntry {
  const _ExistingEntry({
    required this.section,
    required this.heading,
    required this.name,
    required this.bodyLines,
    this.removedOn,
    this.className,
    this.subgroup,
  });

  final String section;
  final String heading;
  final String name;
  final List<String> bodyLines;
  final String? removedOn;
  final String? className;
  final String? subgroup;
}

class _ParsedHeading {
  const _ParsedHeading({
    required this.returnType,
    required this.name,
    required this.parameters,
  });

  final String returnType;
  final String name;
  final List<String> parameters;
}

class _RenameCandidate {
  const _RenameCandidate({
    required this.currentName,
    required this.existing,
    required this.score,
  });

  final String currentName;
  final _ExistingEntry existing;
  final double score;
}

class _DependencyLink {
  const _DependencyLink({
    required this.name,
    required this.docPath,
    required this.exists,
  });

  final String name;
  final String docPath;
  final bool exists;
}
