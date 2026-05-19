const ts = require('typescript');
const {
  hasModifier,
  isPrivateName,
  lineNumber,
  methodName,
  propertyName,
} = require('../base');

function collectTopLevelSymbols(statement, sourceFile, symbols) {
  if (ts.isFunctionDeclaration(statement) && statement.parent === sourceFile) {
    symbols.push(parseFunction(statement, sourceFile));
    return true;
  }

  if (ts.isVariableStatement(statement)) {
    for (const decl of statement.declarationList.declarations) {
      symbols.push(parseVariable(decl, statement, sourceFile));
    }
    return true;
  }

  return false;
}

function parseFunction(node, sourceFile) {
  const name = node.name ? node.name.text : 'anonymous';
  return {
    kind: 'function',
    name,
    signature: `${node.type ? node.type.getText(sourceFile) : 'void'} ${name}(${(node.parameters || []).map((param) => param.getText(sourceFile)).join(', ')})`,
    returnType: node.type ? node.type.getText(sourceFile) : 'void',
    visibility: isPrivateName(name) ? 'private' : 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    parameters: [],
    metadata: {
      isGetter: false,
      isSetter: false,
      isExternal: false,
      isAsync: hasModifier(node.modifiers, ts.SyntaxKind.AsyncKeyword),
    },
  };
}

function parseVariable(decl, statement, sourceFile) {
  const name = decl.name.getText(sourceFile);
  return {
    kind: 'variable',
    name,
    typeAnnotation: decl.type ? decl.type.getText(sourceFile) : undefined,
    visibility: isPrivateName(name) ? 'private' : 'public',
    lineStart: lineNumber(sourceFile, decl.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, decl.end),
    metadata: {
      isConst: hasModifier(statement.modifiers, ts.SyntaxKind.ConstKeyword),
      isFinal: hasModifier(statement.modifiers, ts.SyntaxKind.ReadonlyKeyword),
      isLate: false,
    },
  };
}

module.exports = {
  collectTopLevelSymbols,
};
