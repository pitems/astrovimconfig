# Documentation: documentation_orchestrator

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/tools/documentation_cli/lib/src/orchestrator/documentation_orchestrator.dart`
- Documentation: `/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/orchestrator/documentation_orchestrator.md`
- Generated: `2026-05-14T22:18:34.366947Z`

## Classes

### DocumentationOrchestrator

Coordinates the selected analyzer and returns the normalized result to the CLI. This class keeps the CLI thin by isolating analyzer lookup from the command layer.

#### Variables

##### final AnalyzerRegistry registry
Holds the language registry used to resolve the correct analyzer for a file type. The CLI never talks to analyzers directly; it always asks this registry first.

#### Constructors

##### DocumentationOrchestrator({AnalyzerRegistry? registry})

#### Functions

##### Future<DocumentationResult> analyze(DocumentationRequest request)
Looks up the analyzer and delegates the request to it. If the language is unsupported, the orchestrator is where the failure is raised.


## Deprecated

_No deprecated entries yet._

## Dependencies

- [documentation_request](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_request.md)
- [documentation_result](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/models/documentation_result.md)
- [analyzer_registry](/Users/pitems/.config/nvim/tools/documentation_cli/documentation/src/orchestrator/analyzer_registry.md)
