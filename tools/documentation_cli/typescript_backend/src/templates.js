const sectionOrder = [
  'overview',
  'variables',
  'interfaces',
  'enums',
  'type-aliases',
  'classes',
  'functions',
  'deprecated',
  'dependencies',
  'notes',
];

const headings = {
  overview: 'Overview',
  variables: 'Variables',
  interfaces: 'Interfaces',
  enums: 'Enums',
  'type-aliases': 'Type Aliases',
  classes: 'Classes',
  functions: 'Functions',
  deprecated: 'Deprecated',
  dependencies: 'Dependencies',
  notes: 'Notes',
};

function moduleTemplate(title) {
  return {
    name: 'typescript_module',
    title,
    layout: 'module',
    sectionOrder,
    headings,
  };
}

function controllerTemplate(title) {
  return {
    name: 'typescript_controller',
    title,
    layout: 'controller',
    sectionOrder,
    headings,
  };
}

module.exports = {
  moduleTemplate,
  controllerTemplate,
};
