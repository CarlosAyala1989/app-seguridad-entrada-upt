'use strict';

const { readdirSync, statSync } = require('node:fs');
const { join } = require('node:path');
const { spawnSync } = require('node:child_process');

const roots = ['server.js', 'src', 'scripts', 'test'];
const files = [];

function collect(path) {
  const stat = statSync(path);
  if (stat.isDirectory()) {
    for (const entry of readdirSync(path)) collect(join(path, entry));
  } else if (path.endsWith('.js')) {
    files.push(path);
  }
}

for (const root of roots) collect(root);
for (const file of files) {
  const result = spawnSync(process.execPath, ['--check', file], {
    encoding: 'utf8',
  });
  if (result.status !== 0) {
    process.stderr.write(result.stderr);
    process.exit(result.status || 1);
  }
}

console.log(`Análisis estático completado: ${files.length} archivos JavaScript.`);
