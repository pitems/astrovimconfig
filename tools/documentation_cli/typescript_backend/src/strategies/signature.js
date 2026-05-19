const ts = require('typescript');
const { hasModifier, methodName } = require('./base');

function buildConstructorSignature(node, sourceFile, className) {
  return `${className}(${buildParameterText(node.parameters, sourceFile)})`;
}

function buildMethodSignature(node, sourceFile) {
  const returnType = node.type ? node.type.getText(sourceFile) : 'void';
  const name = methodName(node.name, sourceFile);
  const kind = ts.isGetAccessorDeclaration(node)
    ? 'getter'
    : ts.isSetAccessorDeclaration(node)
      ? 'setter'
      : 'function';

  if (kind === 'getter') {
    return `${returnType} get ${name}`;
  }

  if (kind === 'setter') {
    return `set ${name}(${buildParameterText(node.parameters, sourceFile)})`;
  }

  return `${returnType} ${name}${buildTypeParameterClause(node, sourceFile)}(${buildParameterText(node.parameters, sourceFile)})`;
}

function buildFunctionSignature(node, sourceFile) {
  const returnType = node.type ? node.type.getText(sourceFile) : 'void';
  const name = node.name ? node.name.text : 'anonymous';
  return `${returnType} ${name}${buildTypeParameterClause(node, sourceFile)}(${buildParameterText(node.parameters, sourceFile)})`;
}

function buildInterfaceMethodSignature(node, sourceFile) {
  const returnType = node.type ? node.type.getText(sourceFile) : 'void';
  const name = methodName(node.name, sourceFile);
  return `${returnType} ${name}${buildTypeParameterClause(node, sourceFile)}(${buildParameterText(node.parameters, sourceFile)})`;
}

function buildPropertySignature(name, options = {}) {
  const parts = [];
  if (options.static) {
    parts.push('static');
  }
  if (options.readonly) {
    parts.push('readonly');
  }

  const suffix = options.optional ? '?' : '';
  const type = options.type && options.type.length > 0 ? options.type : 'unknown';
  parts.push(`${name}${suffix}: ${type}`);
  return parts.join(' ');
}

function buildVueFunctionSignature(member, sourceFile) {
  const initializer = member.initializer;
  if (initializer && ts.isFunctionLike(initializer)) {
    const returnType = initializer.type ? initializer.type.getText(sourceFile) : 'void';
    const name = member.name.getText(sourceFile);
    return `${returnType} ${name}(${buildParameterText(initializer.parameters, sourceFile)})`;
  }

  return `${member.name.getText(sourceFile)}()`;
}

function buildParameterText(parameters, sourceFile) {
  return (parameters || []).map((param) => param.getText(sourceFile)).join(', ');
}

function buildTypeParameterClause(node, sourceFile) {
  if (!node.typeParameters || node.typeParameters.length === 0) {
    return '';
  }

  const text = node.typeParameters.map((param) => param.getText(sourceFile)).join(', ');
  return `<${text}>`;
}

module.exports = {
  buildConstructorSignature,
  buildFunctionSignature,
  buildInterfaceMethodSignature,
  buildMethodSignature,
  buildPropertySignature,
  buildVueFunctionSignature,
  buildParameterText,
  buildTypeParameterClause,
};
