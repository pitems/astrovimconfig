# Documentation: module

## Overview

- Language: `typescript`
- Source: `/Users/pitems/.config/nvim/module.ts`
- Documentation: `/Users/pitems/.config/nvim/documentation/module.md`
- Generated: `2026-05-13T17:02:21.320Z`

## Interfaces

### NamedItem
- Properties:
  - `name: string`


### MenuItem
- Extends: `NamedItem`
- Properties:
  - `title: string`
  - `icon?: string`
- Methods:
  - `string render()`


## Enums

### MenuKind
- Const enum: `yes`
- Members:
  - `primary` = `'primary'`
  - `secondary` = `'secondary'`


## Type Aliases

### MenuTitle
- Alias: `string | number`


### MenuMap
- Alias: `Record<string, T>`
- Type parameters: `T`


## Classes

_No entries detected yet._

## Functions

### string helperV3<T extends MenuTitle>(input: T)
**Parameters**
- `input` (T): ----


### string formatLabel<T extends MenuTitle>(input: T)
**Parameters**
- `input` (T): ----


## Deprecated

### string helperV2<T extends MenuTitle>(input: T) ⚠️ Deprecated
- Removed on `2026-05-13`

## Dependencies

_No internal dependencies detected yet._