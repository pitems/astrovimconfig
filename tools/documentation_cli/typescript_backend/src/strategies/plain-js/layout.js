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
  detectLayout,
};
