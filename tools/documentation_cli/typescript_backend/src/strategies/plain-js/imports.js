function collectImports(statement, context, dependencies, references) {
  const ref = context.resolveImport(statement);
  if (!ref) {
    return;
  }

  dependencies.push(ref.dependency);
  references.push(ref.reference);
}

module.exports = {
  collectImports,
};
