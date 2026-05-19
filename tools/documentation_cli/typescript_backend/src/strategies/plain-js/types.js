const ts = require('typescript');
const {
  hasModifier,
  lineNumber,
  methodName,
  propertyName,
} = require('../base');
const {
  buildInterfaceMethodSignature,
  buildPropertySignature,
} = require('../signature');

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
    signature: buildPropertySignature(name, {
      type: typeAnnotation || 'unknown',
      optional: Boolean(member.questionToken),
    }),
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
    signature: buildInterfaceMethodSignature(member, sourceFile),
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

module.exports = {
  parseEnum,
  parseInterface,
  parseTypeAlias,
};
