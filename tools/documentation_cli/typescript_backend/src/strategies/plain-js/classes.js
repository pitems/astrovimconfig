const ts = require('typescript');
const {
  hasModifier,
  isPrivateName,
  lineNumber,
  methodName,
  propertyName,
} = require('../base');
const {
  buildConstructorSignature,
  buildMethodSignature,
  buildPropertySignature,
} = require('../signature');

function collectClassSymbol(statement, sourceFile, symbols) {
  if (!ts.isClassDeclaration(statement)) {
    return false;
  }

  symbols.push(parseClass(statement, sourceFile));
  return true;
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

function parseConstructor(node, sourceFile, className) {
  return {
    kind: 'constructor',
    name: node.name ? node.name.text : className,
    signature: buildConstructorSignature(node, sourceFile, className),
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
    signature: buildPropertySignature(name, {
      type: typeAnnotation,
      static: hasModifier(node.modifiers, ts.SyntaxKind.StaticKeyword),
      readonly: hasModifier(node.modifiers, ts.SyntaxKind.ReadonlyKeyword),
    }),
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
  const kind = ts.isGetAccessorDeclaration(node)
    ? 'getter'
    : ts.isSetAccessorDeclaration(node)
      ? 'setter'
      : 'function';

  return {
    kind,
    name: methodName(node.name, sourceFile),
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

module.exports = {
  collectClassSymbol,
};
