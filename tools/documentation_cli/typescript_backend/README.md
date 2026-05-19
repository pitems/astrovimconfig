# TypeScript Backend

This folder contains the Node-based TypeScript analysis backend used by the
documentation CLI.

## Setup

Install the compiler API dependency:

```bash
npm install
```

## Run

The Dart CLI calls this backend automatically when `typescript_backend/src/index.js`
is present.

You can also run it directly by piping a JSON request into stdin:

```bash
node src/index.js < request.json
```

## Notes

- The backend uses the TypeScript compiler API.
- It returns the same normalized documentation JSON contract that the Dart
  renderer expects.
- The current implementation extracts classes, constructors, fields, methods,
  top-level functions, top-level variables, and internal imports.
