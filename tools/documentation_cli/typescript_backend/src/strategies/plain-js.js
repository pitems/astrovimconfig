const ts = require('typescript');
const {
  hasModifier,
  isPrivateName,
  lineNumber,
  methodName,
  propertyName,
} = require('./base');

function parsePlainJsFile(context) {
  const { sourceFile, projectRoot, sourcePath } = context;
  const symbols = [];
  const dependencies = [];
  const references = [];

  for (const statement of sourceFile.statements) {
    if (ts.isImportDeclaration(statement)) {
      const ref = context.resolveImport(statement);
      if (ref) {
        dependencies.push(ref.dependency);
        references.push(ref.reference);
      }
      continue;
    }

    if (ts.isFunctionDeclaration(statement) && statement.parent === sourceFile) {
      symbols.push(parseFunction(statement, sourceFile));
      continue;
    }

    if (ts.isVariableStatement(statement)) {
      for (const decl of statement.declarationList.declarations) {
        symbols.push(parseVariable(decl, statement, sourceFile));
      }
      continue;
    }

    if (ts.isClassDeclaration(statement)) {
      symbols.push(parseClass(statement, sourceFile));
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

function parseClass(node, sourceFile) {
  const name = node.name ? node.name.text : 'AnonymousClass';
  const children = [];

  for (const member of node.members) {
    if (ts.isConstructorDeclaration(member)) {
      children.push(parseConstructor(member, sourceFile, name));
      continue;
    }

    if (ts.isPropertyDeclaration(member)) {
      children.push(parseProperty(member, sourceFile));
      continue;
    }

    if (ts.isGetAccessorDeclaration(member) || ts.isSetAccessorDeclaration(member) || ts.isMethodDeclaration(member)) {
      children.push(parseMethod(member, sourceFile));
      continue;
    }
  }

  return {
    kind: 'class',
    name,
    visibility: isPrivateName(name) ? 'private' : 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    metadata: {
      isAbstract: hasModifier(node.modifiers, ts.SyntaxKind.AbstractKeyword),
      ...(node.typeParameters && node.typeParameters.length > 0
        ? { typeParameters: node.typeParameters.map((param) => param.name.getText(sourceFile)) }
        : {}),
    },
    children,
  };
}

function parseInterface(node, sourceFile) {
  const name = node.name ? node.name.text : 'AnonymousInterface';
  const children = [];

  for (const member of node.members) {
    if (ts.isPropertySignature(member)) {
      children.push(parseInterfaceProperty(member, sourceFile));
      continue;
    }

    if (ts.isMethodSignature(member)) {
      children.push(parseInterfaceMethod(member, sourceFile));
      continue;
    }
  }

  return {
    kind: 'interface',
    name,
    visibility: 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    metadata: {
      isAbstract: true,
      ...(node.typeParameters && node.typeParameters.length > 0
        ? { typeParameters: node.typeParameters.map((param) => param.name.getText(sourceFile)) }
        : {}),
    },
    children,
  };
}

function parseEnum(node, sourceFile) {
  return {
    kind: 'enum',
    name: node.name ? node.name.text : 'AnonymousEnum',
    visibility: 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    metadata: {
      memberCount: node.members.length,
      isConst: hasModifier(node.modifiers, ts.SyntaxKind.ConstKeyword),
    },
    children: node.members.map((member) => ({
      kind: 'enum-member',
      name: member.name.getText(sourceFile),
      visibility: 'public',
      lineStart: lineNumber(sourceFile, member.getStart(sourceFile)),
      lineEnd: lineNumber(sourceFile, member.end),
      metadata: {
        value: member.initializer ? member.initializer.getText(sourceFile) : undefined,
      },
    })),
  };
}

function parseTypeAlias(node, sourceFile) {
  return {
    kind: 'type-alias',
    name: node.name ? node.name.text : 'AnonymousType',
    visibility: 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    metadata: {
      type: node.type ? node.type.getText(sourceFile) : '',
      ...(node.typeParameters && node.typeParameters.length > 0
        ? { typeParameters: node.typeParameters.map((param) => param.name.getText(sourceFile)) }
        : {}),
    },
  };
}

function parseInterfaceProperty(member, sourceFile) {
  const name = propertyName(member.name, sourceFile);
  const typeAnnotation = member.type ? member.type.getText(sourceFile) : undefined;
  return {
    kind: 'field',
    name,
    signature: `${name}${member.questionToken ? '?' : ''}: ${typeAnnotation || 'unknown'}`,
    typeAnnotation,
    visibility: 'public',
    lineStart: lineNumber(sourceFile, member.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, member.end),
    metadata: {
      isStatic: false,
      isConst: false,
      isFinal: Boolean(member.readonlyToken),
      isLate: false,
    },
  };
}

function parseInterfaceMethod(member, sourceFile) {
  const name = methodName(member.name, sourceFile);
  return {
    kind: 'function',
    name,
    signature: `${member.type ? member.type.getText(sourceFile) : 'void'} ${name}(${(member.parameters || []).map((param) => param.getText(sourceFile)).join(', ')})`,
    returnType: member.type ? member.type.getText(sourceFile) : 'void',
    visibility: 'public',
    lineStart: lineNumber(sourceFile, member.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, member.end),
    parameters: [],
    metadata: {
      isStatic: false,
      isAbstract: true,
      isGetter: false,
      isSetter: false,
      isAsync: false,
    },
  };
}

function parseConstructor(node, sourceFile, className) {
  return {
    kind: 'constructor',
    name: node.name ? node.name.text : className,
    signature: `${className}(${(node.parameters || []).map((param) => param.getText(sourceFile)).join(', ')})`,
    visibility: 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    parameters: [],
    metadata: {
      isConst: hasModifier(node.modifiers, ts.SyntaxKind.ConstKeyword),
      isFactory: false,
    },
  };
}

function parseProperty(node, sourceFile) {
  const name = propertyName(node.name, sourceFile);
  const typeAnnotation = node.type ? node.type.getText(sourceFile) : undefined;
  return {
    kind: 'field',
    name,
    signature: name,
    typeAnnotation,
    visibility: isPrivateName(name) ? 'private' : 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    metadata: {
      isStatic: hasModifier(node.modifiers, ts.SyntaxKind.StaticKeyword),
      isConst: hasModifier(node.modifiers, ts.SyntaxKind.ConstKeyword),
      isFinal: hasModifier(node.modifiers, ts.SyntaxKind.ReadonlyKeyword),
      isLate: false,
    },
  };
}

function parseMethod(node, sourceFile) {
  const name = methodName(node.name, sourceFile);
  const kind = ts.isGetAccessorDeclaration(node)
    ? 'getter'
    : ts.isSetAccessorDeclaration(node)
      ? 'setter'
      : 'function';

  return {
    kind,
    name,
    signature: `${node.type ? node.type.getText(sourceFile) : 'void'} ${name}(${(node.parameters || []).map((param) => param.getText(sourceFile)).join(', ')})`,
    returnType: node.type ? node.type.getText(sourceFile) : (kind === 'getter' ? undefined : 'void'),
    visibility: isPrivateName(name) ? 'private' : 'public',
    lineStart: lineNumber(sourceFile, node.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, node.end),
    parameters: [],
    metadata: {
      isStatic: hasModifier(node.modifiers, ts.SyntaxKind.StaticKeyword),
      isAbstract: hasModifier(node.modifiers, ts.SyntaxKind.AbstractKeyword),
      isGetter: kind === 'getter',
      isSetter: kind === 'setter',
      isAsync: hasModifier(node.modifiers, ts.SyntaxKind.AsyncKeyword),
    },
  };
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

function detectLayout(symbols) {
  const classes = symbols.filter((symbol) => symbol.kind === 'class');
  const topLevelFunctions = symbols.filter((symbol) => symbol.kind === 'function').length;
  const topLevelVariables = symbols.filter((symbol) => symbol.kind === 'variable').length;

  if (classes.length === 0) {
    return 'module';
  }

  const primaryClass = classes[0];
  const name = primaryClass.name || '';
  const controllerName = /(controller|bloc|manager|state|cubit)$/i.test(name);
  const memberCount = classes.reduce((sum, symbol) => sum + (symbol.children ? symbol.children.length : 0), 0);
  const classDominates = memberCount >= 1 && memberCount >= (topLevelFunctions + topLevelVariables);

  if (controllerName && classDominates) {
    return 'controller';
  }

  return 'module';
}

module.exports = {
  parsePlainJsFile,
};
