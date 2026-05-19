const fs = require('fs');
const path = require('path');
const ts = require('typescript');

function createSourceFile(request) {
  // Normalize the source file once so every strategy works from the same AST.
  const sourcePath = request.sourcePath;
  const sourceText = request.sourceText ?? fs.readFileSync(sourcePath, 'utf8');
  const scriptKind = sourcePath.endsWith('.tsx')
    ? ts.ScriptKind.TSX
    : sourcePath.endsWith('.jsx')
      ? ts.ScriptKind.JSX
      : sourcePath.endsWith('.js')
        ? ts.ScriptKind.JS
        : ts.ScriptKind.TS;
  const sourceFile = ts.createSourceFile(sourcePath, sourceText, ts.ScriptTarget.Latest, true, scriptKind);
  const projectRoot = request.projectRoot || guessProjectRoot(sourcePath);

  return {
    sourcePath,
    sourceText,
    sourceFile,
    projectRoot,
  };
}

function guessProjectRoot(sourcePath) {
  let current = path.dirname(sourcePath);

  while (true) {
    if (fs.existsSync(path.join(current, 'package.json')) || fs.existsSync(path.join(current, 'tsconfig.json'))) {
      return current;
    }

    const parent = path.dirname(current);
    if (parent === current) {
      break;
    }
    current = parent;
  }

  return path.dirname(sourcePath);
}

function lineNumber(sourceFile, offset) {
  return sourceFile.getLineAndCharacterOfPosition(offset).line + 1;
}

function hasModifier(modifiers, kind) {
  return Boolean(modifiers && modifiers.some((modifier) => modifier.kind === kind));
}

function isPrivateName(name) {
  return typeof name === 'string' && name.startsWith('_');
}

function methodName(nameNode, sourceFile) {
  if (!nameNode) {
    return 'anonymous';
  }
  return nameNode.getText(sourceFile);
}

function propertyName(nameNode, sourceFile) {
  return nameNode ? nameNode.getText(sourceFile) : 'anonymous';
}

function capitalizeFirstLetter(value) {
  if (!value) {
    return value;
  }
  return value.charAt(0).toUpperCase() + value.slice(1);
}

function isVueStyleSource(sourceText) {
  return /\bVue\.createApp\s*\(/.test(sourceText) || /\bcreateApp\s*\(/.test(sourceText);
}

function inferJsValueType(expression, sourceFile) {
  if (ts.isStringLiteral(expression) || ts.isNoSubstitutionTemplateLiteral(expression)) {
    return 'string';
  }
  if (ts.isNumericLiteral(expression)) {
    return 'number';
  }
  if (expression.kind === ts.SyntaxKind.TrueKeyword || expression.kind === ts.SyntaxKind.FalseKeyword) {
    return 'boolean';
  }
  if (ts.isArrayLiteralExpression(expression)) {
    return 'array';
  }
  if (ts.isObjectLiteralExpression(expression)) {
    return 'object';
  }
  if (ts.isArrowFunction(expression) || ts.isFunctionExpression(expression)) {
    return 'function';
  }
  return expression.getText(sourceFile) ? 'unknown' : 'unknown';
}

function resolveImport(statement, sourceFile, projectRoot, sourcePath) {
  // Keep internal imports resolvable to both the source file and its mirrored doc.
  const moduleText = statement.moduleSpecifier.getText(sourceFile).replace(/^['"]|['"]$/g, '');
  if (!moduleText.startsWith('.') && !moduleText.startsWith('/')) {
    return null;
  }

  const sourceAbsolute = resolveImportSourcePath(moduleText, sourcePath);
  const docPath = sourceToDocPath(sourceAbsolute, projectRoot);
  const name = path.basename(moduleText).replace(/\.[^.]+$/, '');
  return {
    dependency: {
      kind: 'import',
      path: moduleText,
      name,
      lineStart: lineNumber(sourceFile, statement.getStart(sourceFile)),
      lineEnd: lineNumber(sourceFile, statement.end),
      metadata: {
        internal: true,
      },
    },
    reference: {
      name,
      sourcePath: sourceAbsolute,
      docPath,
      exists: fs.existsSync(docPath),
      kind: 'import',
    },
  };
}

function resolveImportSourcePath(moduleText, sourcePath) {
  const sourceDir = path.dirname(sourcePath);
  const resolved = path.resolve(sourceDir, moduleText);
  const candidates = [
    resolved,
    `${resolved}.ts`,
    `${resolved}.tsx`,
    `${resolved}.d.ts`,
    path.join(resolved, 'index.ts'),
    path.join(resolved, 'index.tsx'),
  ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  return `${resolved}.ts`;
}

function sourceToDocPath(sourcePath, projectRoot) {
  // Mirror the source tree under documentation/ so links stay predictable.
  const normalizedRoot = projectRoot.replace(/\\/g, '/').replace(/\/$/, '');
  const normalizedSource = sourcePath.replace(/\\/g, '/');
  const rootPrefix = `${normalizedRoot}/`;
  const srcPrefix = `${normalizedRoot}/src/`;
  const libPrefix = `${normalizedRoot}/lib/`;

  let relative = path.basename(normalizedSource);
  if (normalizedSource.startsWith(srcPrefix)) {
    relative = normalizedSource.substring(srcPrefix.length);
  } else if (normalizedSource.startsWith(libPrefix)) {
    relative = normalizedSource.substring(libPrefix.length);
  } else if (normalizedSource.startsWith(rootPrefix)) {
    relative = normalizedSource.substring(rootPrefix.length);
  }

  relative = relative.replace(/\.[^.]+$/, '');
  return `${normalizedRoot}/documentation/${relative}.md`;
}

module.exports = {
  capitalizeFirstLetter,
  createSourceFile,
  hasModifier,
  inferJsValueType,
  isPrivateName,
  isVueStyleSource,
  lineNumber,
  methodName,
  propertyName,
  resolveImport,
  sourceToDocPath,
};
