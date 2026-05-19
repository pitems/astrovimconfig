import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../models/documentation_result.dart';
import '../models/documentation_symbol.dart';

class DocumentationIndex {
  DocumentationIndex({
    required this.file,
    required this.documents,
  });

  final File file;
  final List<DocumentationIndexEntry> documents;

  static Future<DocumentationIndex> loadForSource(String sourcePath) async {
    final root = _guessProjectRoot(sourcePath);
    final file = File('$root/documentation/.index.json');

    if (!await file.exists()) {
      return DocumentationIndex(file: file, documents: <DocumentationIndexEntry>[]);
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return DocumentationIndex(file: file, documents: <DocumentationIndexEntry>[]);
      }

      final rawDocuments = decoded['documents'] as List<dynamic>? ?? const <dynamic>[];
      final documents = rawDocuments
          .map((item) => DocumentationIndexEntry.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      return DocumentationIndex(file: file, documents: documents);
    } catch (_) {
      return DocumentationIndex(file: file, documents: <DocumentationIndexEntry>[]);
    }
  }

  IndexResolution resolve(DocumentationResult result) {
    final targetDocPath = result.docPath;
    final sourcePath = result.sourcePath;
    final layout = result.template.layout;
    final fingerprint = _fingerprint(result);
    final snapshotTokens = _snapshotTokensFromResult(result);

    final exactSourceMatch = documents.where((entry) => entry.sourcePath == sourcePath).toList();
    DocumentationIndexEntry? matched;

    if (exactSourceMatch.isNotEmpty) {
      matched = exactSourceMatch.first;
    } else {
      final candidates = documents.where((entry) => entry.layout == layout).toList();

      DocumentationIndexEntry? bestFingerprintMatch;
      for (final entry in candidates) {
        if (entry.fingerprint == fingerprint && entry.sourcePath != sourcePath) {
          bestFingerprintMatch = entry;
          break;
        }
      }

      if (bestFingerprintMatch != null) {
        matched = bestFingerprintMatch;
      } else {
        DocumentationIndexEntry? bestSimilarityMatch;
        var bestScore = 0.0;
        for (final entry in candidates) {
          if (entry.sourcePath == sourcePath) {
            continue;
          }
          final score = _snapshotSimilarity(snapshotTokens, _snapshotTokensFromMap(entry.snapshot));
          if (score > bestScore) {
            bestScore = score;
            bestSimilarityMatch = entry;
          }
        }

        if (bestSimilarityMatch != null && bestScore >= 0.6) {
          matched = bestSimilarityMatch;
        }
      }
    }

    final previousDocPath = matched?.docPath ?? targetDocPath;
    final docId = matched?.docId ?? _newDocId();
    final snapshot = _snapshotFor(result);

    return IndexResolution(
      docId: docId,
      sourcePath: sourcePath,
      targetDocPath: targetDocPath,
      sourceDocPath: previousDocPath,
      layout: layout,
      fingerprint: fingerprint,
      snapshot: snapshot,
      sourcePathWasRenamed: matched != null && matched.sourcePath != sourcePath,
    );
  }

  Future<void> upsert(IndexResolution resolution, DocumentationResult result) async {
    final withoutMatched = documents
        .where((entry) => entry.docId != resolution.docId)
        .toList();
    withoutMatched.add(
      DocumentationIndexEntry(
        docId: resolution.docId,
        sourcePath: resolution.sourcePath,
        docPath: resolution.targetDocPath,
        layout: resolution.layout,
        fingerprint: resolution.fingerprint,
        snapshot: resolution.snapshot,
        updatedAt: result.metadata.generatedAt,
      ),
    );
    documents
      ..clear()
      ..addAll(withoutMatched);
  }

  Future<void> save() async {
    await file.parent.create(recursive: true);
    final payload = <String, dynamic>{
      'version': 1,
      'documents': documents.map((entry) => entry.toJson()).toList(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  }

  static String _guessProjectRoot(String sourcePath) {
    final normalized = sourcePath.replaceAll('\\', '/');
    final libIndex = normalized.lastIndexOf('/lib/');
    if (libIndex > 0) {
      return normalized.substring(0, libIndex);
    }
    return File(sourcePath).parent.path;
  }

  static String _fingerprint(DocumentationResult result) {
    final payload = <String, dynamic>{
      'layout': result.template.layout,
      'symbols': _snapshotSymbols(result.symbols),
    };
    return _stableHash(jsonEncode(payload));
  }

  static Map<String, dynamic> _snapshotFor(DocumentationResult result) {
    return <String, dynamic>{
      'layout': result.template.layout,
      'symbols': _snapshotSymbols(result.symbols),
    };
  }

  static Set<String> _snapshotTokensFromResult(DocumentationResult result) {
    return _snapshotTokensFromMap(_snapshotFor(result));
  }

  static Set<String> _snapshotTokensFromMap(Map<String, dynamic> snapshot) {
    final tokens = <String>{};
    final layout = snapshot['layout'] as String? ?? '';
    tokens.add('layout:$layout');

    final symbols = snapshot['symbols'] as List<dynamic>? ?? const <dynamic>[];
    for (final raw in symbols) {
      if (raw is Map) {
        tokens.addAll(_snapshotTokensFromSymbol(Map<String, dynamic>.from(raw)));
      }
    }

    return tokens;
  }

  static Set<String> _snapshotTokensFromSymbol(Map<String, dynamic> symbol) {
    final tokens = <String>{};
    final kind = symbol['kind'] as String? ?? '';
    final name = symbol['name'] as String? ?? '';
    final signature = symbol['signature'] as String? ?? '';
    final typeAnnotation = symbol['typeAnnotation'] as String? ?? '';
    final returnType = symbol['returnType'] as String? ?? '';
    tokens.add('kind:$kind');
    tokens.add('name:$name');
    if (signature.isNotEmpty) {
      tokens.add('signature:$signature');
    }
    if (typeAnnotation.isNotEmpty) {
      tokens.add('type:$typeAnnotation');
    }
    if (returnType.isNotEmpty) {
      tokens.add('return:$returnType');
    }

    final metadata = symbol['metadata'];
    if (metadata is Map) {
      final ordered = _orderedMap(Map<String, dynamic>.from(metadata));
      tokens.addAll(ordered.entries.map((entry) => 'meta:${entry.key}=${entry.value}'));
    }

    final children = symbol['children'] as List<dynamic>? ?? const <dynamic>[];
    for (final rawChild in children) {
      if (rawChild is Map) {
        final child = Map<String, dynamic>.from(rawChild);
        tokens.addAll(_snapshotTokensFromSymbol(child).map((token) => '$name::$token'));
      }
    }

    return tokens;
  }

  static double _snapshotSimilarity(Set<String> a, Set<String> b) {
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

  static List<Map<String, dynamic>> _snapshotSymbols(List<DocumentationSymbol> symbols) {
    final ordered = List<DocumentationSymbol>.from(symbols)
      ..sort((a, b) => _symbolSortKey(a).compareTo(_symbolSortKey(b)));
    return ordered.map(_snapshotSymbol).toList();
  }

  static Map<String, dynamic> _snapshotSymbol(DocumentationSymbol symbol) {
    return <String, dynamic>{
      'kind': symbol.kind,
      'name': symbol.name,
      if (symbol.signature != null) 'signature': symbol.signature,
      if (symbol.returnType != null) 'returnType': symbol.returnType,
      if (symbol.typeAnnotation != null) 'typeAnnotation': symbol.typeAnnotation,
      if (symbol.visibility != null) 'visibility': symbol.visibility,
      if (symbol.metadata.isNotEmpty) 'metadata': _orderedMap(symbol.metadata),
      if (symbol.children.isNotEmpty) 'children': _snapshotSymbols(symbol.children),
    };
  }

  static Map<String, dynamic> _orderedMap(Map<String, dynamic> source) {
    final keys = source.keys.toList()..sort();
    return <String, dynamic>{
      for (final key in keys) key: source[key],
    };
  }

  static String _symbolSortKey(DocumentationSymbol symbol) {
    return '${symbol.kind}:${symbol.name}:${symbol.signature ?? ''}:${symbol.returnType ?? ''}:${symbol.typeAnnotation ?? ''}';
  }

  static String _stableHash(String input) {
    final bytes = utf8.encode(input);
    var hash = BigInt.parse('1469598103934665603');
    final prime = BigInt.from(1099511628211);
    final mask = BigInt.parse('18446744073709551615');

    for (final byte in bytes) {
      hash = (hash ^ BigInt.from(byte)) * prime;
      hash &= mask;
    }

    return hash.toRadixString(16).padLeft(16, '0');
  }

  static String _newDocId() {
    final random = Random();
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final suffix = random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    return 'doc_$timestamp$suffix';
  }
}

class IndexResolution {
  const IndexResolution({
    required this.docId,
    required this.sourcePath,
    required this.targetDocPath,
    required this.sourceDocPath,
    required this.layout,
    required this.fingerprint,
    required this.snapshot,
    required this.sourcePathWasRenamed,
  });

  final String docId;
  final String sourcePath;
  final String targetDocPath;
  final String sourceDocPath;
  final String layout;
  final String fingerprint;
  final Map<String, dynamic> snapshot;
  final bool sourcePathWasRenamed;
}

class DocumentationIndexEntry {
  const DocumentationIndexEntry({
    required this.docId,
    required this.sourcePath,
    required this.docPath,
    required this.layout,
    required this.fingerprint,
    required this.snapshot,
    required this.updatedAt,
  });

  final String docId;
  final String sourcePath;
  final String docPath;
  final String layout;
  final String fingerprint;
  final Map<String, dynamic> snapshot;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'doc_id': docId,
      'source_path': sourcePath,
      'doc_path': docPath,
      'layout': layout,
      'fingerprint': fingerprint,
      'snapshot': snapshot,
      'updated_at': updatedAt,
    };
  }

  factory DocumentationIndexEntry.fromJson(Map<String, dynamic> json) {
    return DocumentationIndexEntry(
      docId: json['doc_id'] as String,
      sourcePath: json['source_path'] as String,
      docPath: json['doc_path'] as String,
      layout: json['layout'] as String? ?? 'module',
      fingerprint: json['fingerprint'] as String? ?? '',
      snapshot: Map<String, dynamic>.from(json['snapshot'] as Map? ?? const {}),
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
