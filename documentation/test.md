# Documentation: test

## Overview

- Language: `dart`
- Source: `/Users/pitems/.config/nvim/test.dart`
- Documentation: `/Users/pitems/.config/nvim/documentation/test.md`
- Generated: `2026-05-13T16:47:26.296266Z`

## Classes

### ReducerManager

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

_No deprecated entries yet._

## Dependencies

- [classtest](/Users/pitems/.config/nvim/documentation/classtest.md)