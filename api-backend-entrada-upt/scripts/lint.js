import { readdirSync } from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const directorios = ['src', 'scripts', 'test'];
const archivos = [];

function recopilarArchivos(directorio) {
  for (const entrada of readdirSync(directorio, { withFileTypes: true })) {
    const ruta = path.join(directorio, entrada.name);

    if (entrada.isDirectory()) {
      recopilarArchivos(ruta);
    } else if (entrada.isFile() && ruta.endsWith('.js')) {
      archivos.push(ruta);
    }
  }
}

for (const directorio of directorios) recopilarArchivos(directorio);
archivos.sort();

for (const archivo of archivos) {
  const resultado = spawnSync(process.execPath, ['--check', archivo], {
    encoding: 'utf8',
  });

  if (resultado.error) {
    process.stderr.write(`${archivo}: ${resultado.error.message}\n`);
    process.exit(1);
  }

  if (resultado.status !== 0) {
    process.stderr.write(resultado.stderr);
    process.exit(resultado.status ?? 1);
  }
}

console.log(`Análisis estático completado: ${archivos.length} archivos JavaScript.`);
