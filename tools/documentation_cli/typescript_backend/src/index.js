#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { parseTypeScript } = require('./parser');
const { moduleTemplate, controllerTemplate } = require('./templates');

function readStdin() {
  return new Promise((resolve, reject) => {
    let input = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => {
      input += chunk;
    });
    process.stdin.on('end', () => resolve(input));
    process.stdin.on('error', reject);
  });
}

function toDocumentationResult(request, parsed) {
  const title = buildTitle(request.sourcePath);
  const template = parsed.layout === 'controller'
    ? controllerTemplate(title)
    : moduleTemplate(title);

  return {
    schemaVersion: '1.0.0',
    language: 'typescript',
    sourcePath: request.sourcePath,
    docPath: request.docPath,
    ...(request.projectRoot ? { projectRoot: request.projectRoot } : {}),
    template,
    symbols: parsed.symbols,
    dependencies: parsed.dependencies,
    references: parsed.references,
    metadata: {
      generatedAt: new Date().toISOString(),
      analyzer: 'typescript-compiler-api',
      toolVersion: '0.1.0',
      sourceLineCount: parsed.sourceText.split('\n').length,
      sourceLength: parsed.sourceText.length,
      layout: parsed.layout,
    },
    warnings: [],
  };
}

function buildTitle(sourcePath) {
  const base = path.basename(sourcePath).replace(/\.[^.]+$/, '');
  return `Documentation: ${base}`;
}

async function main() {
  const stdinText = await readStdin();
  if (!stdinText.trim()) {
    console.error('TypeScript backend expects a JSON request on stdin');
    process.exit(64);
    return;
  }

  let request;
  try {
    request = JSON.parse(stdinText);
  } catch (error) {
    console.error(`Invalid JSON request: ${error.message}`);
    process.exit(64);
    return;
  }

  if (!request || typeof request.sourcePath !== 'string' || typeof request.docPath !== 'string') {
    console.error('Request is missing sourcePath or docPath');
    process.exit(64);
    return;
  }

  try {
    const parsed = parseTypeScript(request);
    const result = toDocumentationResult({
      ...request,
      sourcePath: request.sourcePath,
      docPath: request.docPath,
      projectRoot: request.projectRoot || parsed.projectRoot,
    }, parsed);
    process.stdout.write(JSON.stringify(result));
  } catch (error) {
    console.error(error && error.stack ? error.stack : String(error));
    process.exit(1);
  }
}

main();
