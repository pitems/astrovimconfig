const ts = require('typescript');
const { detectLayout } = require('./layout');
const { collectImports } = require('./imports');
const { collectClassSymbol } = require('./classes');
const { collectTopLevelSymbols } = require('./symbols');
const { parseInterface, parseEnum, parseTypeAlias } = require('./types');

function parsePlainJsFile(context) {
  const { sourceFile, projectRoot } = context;
  const symbols = [];
  const dependencies = [];
  const references = [];

  // Walk the file once and hand each statement to the smallest matching helper.
  for (const statement of sourceFile.statements) {
    if (ts.isImportDeclaration(statement)) {
      collectImports(statement, context, dependencies, references);
      continue;
    }

    if (collectTopLevelSymbols(statement, sourceFile, symbols)) {
      continue;
    }

    if (collectClassSymbol(statement, sourceFile, symbols)) {
      continue;
    }

    if (ts.isInterfaceDeclaration(statement)) {
      symbols.push(parseInterface(statement, sourceFile));
      continue;
    }

    if (ts.isEnumDeclaration(statement)) {
      symbols.push(parseEnum(statement, sourceFile));
      continue;
    }

    if (ts.isTypeAliasDeclaration(statement)) {
      symbols.push(parseTypeAlias(statement, sourceFile));
      continue;
    }
  }

  return {
    sourceText: context.sourceText,
    sourceFile,
    projectRoot,
    symbols,
    dependencies,
    references,
    layout: detectLayout(symbols),
  };
}

module.exports = {
  parsePlainJsFile,
};
