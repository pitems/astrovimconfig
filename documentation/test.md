# Documentation: test

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/test.dart`
- Documentation: `/Users/pitems/.config/nvim/documentation/test.md`
- Generated: `2026-05-13T06:17:32.805571Z`

## Classes

### ReducerManager
> Manual note: this controller owns flow state and should preserve this note.

#### Variables

##### static ReducerManager? _instance

##### int attempts

##### int leCounter

##### String channel

##### final ClassTest service

##### String title

##### late String status

#### Constructors

##### ReducerManager._privateConstructor()

##### ReducerManager({required this.service, required this.title, this.status = 'idle'})

##### factory ReducerManager.fromSeed(int seed)

#### Functions

##### ReducerManager get instance

##### void disposeInstance()

##### void init()

##### Future<void> processText(String input)

##### Future<void> pushOtp({required String phoneNumber, required bool urgent})

##### bool get isReady

##### set setText(String value)

##### String formatTextV2(String prefix, String suffix)
_Renamed from `formatText`_

This is a human note for the formatting helper.
> Manual note: format text before dispatch.

##### String _privateToken()

---

### AuditController

#### Variables

##### final ClassTest service

##### final String sessionId

##### bool active

#### Constructors

##### AuditController({required this.service, required this.sessionId})

##### factory AuditController.fromService(ClassTest service)

#### Functions

##### void start()

##### void stop()

##### Future<void> refresh({required int retryCount})

##### void reset()

##### bool get isRunning

##### String summarize(String prefix)

##### String _privateTag()


## Deprecated

### OtpBloc: OtpBloc({required this.service, required this.title, this.status = 'idle'}) ⚠️ Deprecated
- Removed on `2026-05-13`

### OtpBloc: Future<void> requestVerification({required String phoneNumber, required bool urgent}) ⚠️ Deprecated
- Removed on `2026-05-13`

### OtpBloc: set displayTitle(String value) ⚠️ Deprecated
- Removed on `2026-05-13`

### OtpBloc: String composeSummary(String prefix, String suffix) ⚠️ Deprecated
- Removed on `2026-05-13`

### AuditController: void reset() ⚠️ Deprecated
- Removed on `2026-05-13`

### AuditController: String summarize(String prefix) ⚠️ Deprecated
- Removed on `2026-05-13`

### VerificationBloc: VerificationBloc({required this.service, required this.title, this.status = 'idle'}) ⚠️ Deprecated
- Removed on `2026-05-13`

### VerificationBloc: Future<void> requestOtp({required String phoneNumber, required bool urgent}) ⚠️ Deprecated
- Removed on `2026-05-13`

### VerificationBloc: set displayLabel(String value) ⚠️ Deprecated
- Removed on `2026-05-13`

### VerificationBloc: String buildMessage(String prefix, String suffix) ⚠️ Deprecated
- Removed on `2026-05-13`

### AuditController: int retries ⚠️ Deprecated
- Removed on `2026-05-13`

### AuditController: void resetState() ⚠️ Deprecated
- Removed on `2026-05-13`

### AuditController: String describe(String prefix) ⚠️ Deprecated
- Removed on `2026-05-13`

### StateManager: StateManager({required this.service, required this.title, this.status = 'idle'}) ⚠️ Deprecated
- Removed on `2026-05-13`

### StateManager: Future<void> sendOtp({required String phoneNumber, required bool urgent}) ⚠️ Deprecated
- Removed on `2026-05-13`

### StateManager: set updateLabel(String value) ⚠️ Deprecated
- Removed on `2026-05-13`

### StateManager: String composeMessage(String prefix, String suffix) ⚠️ Deprecated
- Removed on `2026-05-13`

## Dependencies

- [classtest](/Users/pitems/.config/nvim/documentation/classtest.md)