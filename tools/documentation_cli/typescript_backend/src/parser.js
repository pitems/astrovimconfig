const ts = require('typescript');
const { createSourceFile, isVueStyleSource, resolveImport } = require('./strategies/base');
const { parsePlainJsFile } = require('./strategies/plain-js');
const { parseVueAppFile } = require('./strategies/vue');

function parseTypeScript(request) {
  // Build a shared parsing context first so every strategy sees the same
  // source text, source file, and resolved project root.
  const context = createSourceFile(request);
  context.resolveImport = (statement) =>
    resolveImport(statement, context.sourceFile, context.projectRoot, context.sourcePath);

  // Vue-style app objects get their own strategy because they are object-based,
  // not plain top-level declarations.
  if (shouldUseVueStrategy(context)) {
    return parseVueAppFile(context);
  }

  return parsePlainJsFile(context);
}

function shouldUseVueStrategy(context) {
  const normalizedPath = context.sourcePath.toLowerCase();
  if (normalizedPath.endsWith('.vue')) {
    return true;
  }

  if (normalizedPath.endsWith('.js') || normalizedPath.endsWith('.jsx') || normalizedPath.endsWith('.ts') || normalizedPath.endsWith('.tsx')) {
    return isVueStyleSource(context.sourceText);
  }

  for (const statement of context.sourceFile.statements) {
    if (!ts.isVariableStatement(statement)) {
      continue;
    }

    for (const decl of statement.declarationList.declarations) {
      if (decl.initializer && ts.isCallExpression(decl.initializer)) {
        const expression = decl.initializer.expression;
        if (ts.isPropertyAccessExpression(expression) && expression.name.getText(context.sourceFile) === 'createApp') {
          return true;
        }
      }
    }
  }

  return false;
}

module.exports = {
  parseTypeScript,
};
