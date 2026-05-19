# Documentation: documentation_index

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/index/documentation_index.dart`
- Documentation: `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/index/documentation_index.md`
- Generated: `2026-05-14T22:18:34.367667Z`

## Classes

### DocumentationIndex

Stores the hidden document registry and its last known symbol snapshot. This is the machine memory that helps the tool recognize renames, moves, and current file identity without cluttering the markdown itself.

#### Variables

##### final File file
The hidden JSON file on disk. It is the persistent store for the doc identity map.

##### final List<DocumentationIndexEntry> documents
All tracked documents currently known to the tool. Each entry remembers the source path, doc path, layout, and last known snapshot.

#### Constructors

##### DocumentationIndex({required this.file, required this.documents})

#### Functions

##### Future<DocumentationIndex> loadForSource(String sourcePath)
Loads the index and prepares it for a specific source file. This is where the tool starts before it decides whether it is updating, renaming, or creating a document.

##### IndexResolution resolve(DocumentationResult result)
Matches the current result against prior entries and decides whether to reuse, rename, or move a doc. It compares the new snapshot against the previous one and chooses the best matching document slot.

##### Future<void> upsert(IndexResolution resolution, DocumentationResult result)
Writes the current document snapshot back into the index. This keeps the last known source state available for the next rename or deprecation check.

##### Future<void> save()
Persists the index JSON to disk in a stable, pretty-printed form so it stays readable if you inspect it manually.

##### String _guessProjectRoot(String sourcePath)
Finds the repo root that owns the mirrored documentation tree so the index knows which `documentation/.index.json` file to touch.

##### String _fingerprint(DocumentationResult result)
Builds a stable fingerprint for rename and move detection. The fingerprint is intentionally based on the structure, not just the file path.

##### Map<String, dynamic> _snapshotFor(DocumentationResult result)
Extracts the compact snapshot payload stored in the hidden index. The snapshot is the reduced structural view used for future matching.

##### Set<String> _snapshotTokensFromResult(DocumentationResult result)
Collects comparison tokens from the current result so it can be compared against previously stored snapshot data.

##### Set<String> _snapshotTokensFromMap(Map<String, dynamic> snapshot)
Collects comparison tokens from a stored snapshot payload. This keeps the comparison logic symmetric between current and archived state.

##### Set<String> _snapshotTokensFromSymbol(Map<String, dynamic> symbol)
Extracts symbol-level tokens used to compare file history. The output includes kind, names, signatures, and metadata so rename detection has enough signal.

##### double _snapshotSimilarity(Set<String> a, Set<String> b)
Scores how close two snapshots are to one another. The higher the score, the more likely the new file is the same document in a new shape or location.

##### List<Map<String, dynamic>> _snapshotSymbols(List<DocumentationSymbol> symbols)
Serializes the current symbol tree into compact snapshot entries. The ordering is normalized so the stored snapshot does not depend on source ordering quirks.

##### Map<String, dynamic> _snapshotSymbol(DocumentationSymbol symbol)
Serializes a single symbol and its children into index JSON. This is what preserves the last known class/function tree in the hidden store.

##### Map<String, dynamic> _orderedMap(Map<String, dynamic> source)
Keeps snapshot JSON stable so diffs stay predictable and the fingerprint stays deterministic.

##### String _symbolSortKey(DocumentationSymbol symbol)
Produces a deterministic ordering key for snapshot comparisons so the same symbols always hash the same way.

##### String _stableHash(String input)
Hashes text into a compact stable identity token using a deterministic 64-bit style hash.

##### String _newDocId()
Generates a new document identity when no previous entry matches. This is the fallback identity used for new documents.

---

### IndexResolution

This is the result of matching the current analysis against the hidden index. It tells the CLI which path to write to and whether the source was treated as a rename.

#### Variables

##### final String docId
The stable identity assigned to this document.

##### final String sourcePath
The current source file path being documented.

##### final String targetDocPath
The doc path the current run should write to.

##### final String sourceDocPath
The previous doc path that should be reused or moved if the file was renamed.

##### final String layout
The detected layout stored in the index.

##### final String fingerprint
The stable fingerprint for the current symbol snapshot.

##### final Map<String, dynamic> snapshot
The compact structural snapshot stored for future rename matching.

##### final bool sourcePathWasRenamed
True when the current source path did not match the last known path for this document.

#### Constructors

##### const IndexResolution({required this.docId, required this.sourcePath, required this.targetDocPath, required this.sourceDocPath, required this.layout, required this.fingerprint, required this.snapshot, required this.sourcePathWasRenamed})
Captures the chosen file identity, destination, and snapshot state for one update pass. This is the handoff from matching logic to the write step.

---

### DocumentationIndexEntry

Represents one persisted record in the hidden index JSON file.

Represents one persisted record in `documentation/.index.json`. Each entry is the small memory block that lets the tool recognize a document later.

#### Variables

##### final String docId
The stable document identity token.

##### final String sourcePath
The last known source file path.

##### final String docPath
The current mirrored markdown path.

##### final String layout
The layout stored for this document, such as module or controller.

##### final String fingerprint
The stable structural fingerprint used for rename comparison.

##### final Map<String, dynamic> snapshot
The compact snapshot of the symbol tree.

##### final String updatedAt
The timestamp of the last successful update.

#### Constructors

##### const DocumentationIndexEntry({required this.docId, required this.sourcePath, required this.docPath, required this.layout, required this.fingerprint, required this.snapshot, required this.updatedAt})

##### factory DocumentationIndexEntry.fromJson(Map<String, dynamic> json)

#### Functions

##### Map<String, dynamic> toJson()
Serializes the entry back into JSON so the hidden index can be saved.
Converts the index entry back into JSON for storage so it can be written back into the hidden file.


## Deprecated

_No deprecated entries yet._

## Dependencies

- [documentation_result](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_result.md)
- [documentation_symbol](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_symbol.md)
