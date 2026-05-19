const ts = require('typescript');
const {
  capitalizeFirstLetter,
  hasModifier,
  inferJsValueType,
  isPrivateName,
  lineNumber,
  methodName,
  propertyName,
} = require('./base');
const {
  buildMethodSignature,
  buildPropertySignature,
  buildVueFunctionSignature,
} = require('./signature');

function parseVueAppFile(context) {
  const { sourceFile, projectRoot } = context;
  const symbols = [];
  const dependencies = [];
  const references = [];

  // Vue SFC-style app files still start as normal JS, but the app body lives
  // inside the createApp object instead of top-level declarations.
  for (const statement of sourceFile.statements) {
    if (ts.isImportDeclaration(statement)) {
      const ref = context.resolveImport(statement);
      if (ref) {
        dependencies.push(ref.dependency);
        references.push(ref.reference);
      }
      continue;
    }

    if (ts.isVariableStatement(statement)) {
      for (const decl of statement.declarationList.declarations) {
        const vueAppSymbol = parseVueAppDeclaration(decl, sourceFile);
        if (vueAppSymbol) {
          symbols.push(vueAppSymbol);
        }
        symbols.push(parseVariable(decl, statement, sourceFile));
      }
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

function parseVueAppDeclaration(decl, sourceFile) {
  if (!decl.initializer || !ts.isCallExpression(decl.initializer)) {
    return null;
  }

  const call = decl.initializer;
  if (!isVueCreateAppCall(call, sourceFile)) {
    return null;
  }

  const optionsObject = extractVueOptionsObject(call);
  if (!optionsObject) {
    return null;
  }

  const appName = capitalizeFirstLetter(decl.name.getText(sourceFile) || 'VueApp');
  const children = parseVueOptionsObject(optionsObject, sourceFile);

  return {
    kind: 'class',
    name: appName,
    visibility: 'public',
    lineStart: lineNumber(sourceFile, decl.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, decl.end),
    metadata: {
      isAbstract: false,
      framework: 'vue',
      source: 'createApp',
      appVariable: decl.name.getText(sourceFile),
    },
    children,
  };
}

function parseVueOptionsObject(optionsObject, sourceFile) {
  const children = [];

  // Pull out the common Vue option buckets we care about for notes/docs.
  for (const member of optionsObject.properties) {
    if (ts.isMethodDeclaration(member)) {
      const memberName = propertyName(member.name, sourceFile);
      if (memberName === 'data') {
        children.push(...parseVueDataMethod(member, sourceFile));
        continue;
      }

      children.push(parseMethod(member, sourceFile));
      continue;
    }

    if (ts.isPropertyAssignment(member)) {
      const memberName = propertyName(member.name, sourceFile);
      const value = member.initializer;

      if (memberName === 'data' && ts.isArrowFunction(value)) {
        children.push(...parseVueDataArrow(value, sourceFile));
        continue;
      }

      if (memberName === 'methods' && ts.isObjectLiteralExpression(value)) {
        for (const methodMember of value.properties) {
          if (ts.isMethodDeclaration(methodMember)) {
            children.push(parseMethod(methodMember, sourceFile));
            continue;
          }
          if (ts.isPropertyAssignment(methodMember) && ts.isFunctionLike(methodMember.initializer)) {
            children.push(parseVueFunctionProperty(methodMember, sourceFile));
          }
        }
        continue;
      }

      if (memberName === 'computed' && ts.isObjectLiteralExpression(value)) {
        for (const computedMember of value.properties) {
          if (ts.isMethodDeclaration(computedMember)) {
            children.push(parseMethod(computedMember, sourceFile));
            continue;
          }
          if (ts.isPropertyAssignment(computedMember) && ts.isFunctionLike(computedMember.initializer)) {
            children.push(parseVueFunctionProperty(computedMember, sourceFile));
          }
        }
        continue;
      }

      if (ts.isFunctionLike(value)) {
        children.push(parseVueFunctionProperty(member, sourceFile));
        continue;
      }
    }
  }

  return children;
}

function parseVueDataMethod(member, sourceFile) {
  const body = member.body;
  if (!body) {
    return [];
  }

  for (const statement of body.statements) {
    if (!ts.isReturnStatement(statement) || !statement.expression) {
      continue;
    }

    if (ts.isObjectLiteralExpression(statement.expression)) {
      return parseObjectLiteralAsFields(statement.expression, sourceFile);
    }
  }

  return [parseMethod(member, sourceFile)];
}

function parseVueDataArrow(arrow, sourceFile) {
  const body = arrow.body;
  if (!ts.isObjectLiteralExpression(body)) {
    return [];
  }

  return parseObjectLiteralAsFields(body, sourceFile);
}

function parseObjectLiteralAsFields(objectLiteral, sourceFile) {
  // Vue data objects become documented fields so the state reads like a class.
  return objectLiteral.properties
    .filter((property) => ts.isPropertyAssignment(property))
    .map((property) => {
      const propertyAssignment = property;
      const name = propertyName(propertyAssignment.name, sourceFile);
      const typeAnnotation = inferJsValueType(propertyAssignment.initializer, sourceFile);
      return {
        kind: 'field',
        name,
        typeAnnotation,
        signature: buildPropertySignature(name, {
          type: typeAnnotation,
        }),
        visibility: 'public',
        lineStart: lineNumber(sourceFile, propertyAssignment.getStart(sourceFile)),
        lineEnd: lineNumber(sourceFile, propertyAssignment.end),
        metadata: {
          isConst: false,
          isFinal: false,
          isLate: false,
          framework: 'vue',
        },
      };
    });
}

function parseVueFunctionProperty(member, sourceFile) {
  const name = propertyName(member.name, sourceFile);
  const initializer = member.initializer;
  return {
    kind: 'function',
    name,
    signature: buildVueFunctionSignature(member, sourceFile),
    returnType: 'void',
    visibility: isPrivateName(name) ? 'private' : 'public',
    lineStart: lineNumber(sourceFile, member.getStart(sourceFile)),
    lineEnd: lineNumber(sourceFile, member.end),
    parameters: initializer && ts.isFunctionLike(initializer)
      ? initializer.parameters.map((param) => ({
          name: param.name.getText(sourceFile),
          type: param.type ? param.type.getText(sourceFile) : undefined,
          isRequired: !param.questionToken && !param.initializer,
          isNamed: false,
          defaultValue: param.initializer ? param.initializer.getText(sourceFile) : undefined,
          accessibility: null,
          isReadonly: hasModifier(param.modifiers, ts.SyntaxKind.ReadonlyKeyword),
          isParameterProperty: false,
        }))
      : [],
    metadata: {
      isGetter: false,
      isSetter: false,
      isExternal: false,
      isAsync: Boolean(initializer && ts.isFunctionLike(initializer) && hasModifier(initializer.modifiers, ts.SyntaxKind.AsyncKeyword)),
      framework: 'vue',
    },
  };
}

function parseMethod(node, sourceFile) {
  const kind = ts.isGetAccessorDeclaration(node)
    ? 'getter'
    : ts.isSetAccessorDeclaration(node)
      ? 'setter'
      : 'function';
  const name = methodName(node.name, sourceFile);

  return {
    kind,
    name,
    signature: buildMethodSignature(node, sourceFile),
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

function isVueCreateAppCall(callExpression, sourceFile) {
  const expression = callExpression.expression;
  if (ts.isPropertyAccessExpression(expression)) {
    return expression.name.getText(sourceFile) === 'createApp';
  }
  return ts.isIdentifier(expression) && expression.getText(sourceFile) === 'createApp';
}

function extractVueOptionsObject(callExpression) {
  if (!callExpression.arguments || callExpression.arguments.length === 0) {
    return null;
  }

  const firstArgument = callExpression.arguments[0];
  if (ts.isObjectLiteralExpression(firstArgument)) {
    return firstArgument;
  }

  return null;
}

module.exports = {
  parseVueAppFile,
};
