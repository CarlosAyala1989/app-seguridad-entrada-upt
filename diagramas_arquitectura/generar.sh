#!/usr/bin/env bash
# Crea el entorno aislado y genera las imágenes desde cualquier directorio.
set -euo pipefail

DIRECTORIO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_DIAGRAMAS="${PYTHON_DIAGRAMAS:-python3}"

if [[ ! -x "$DIRECTORIO/.venv/bin/python" ]]; then
  "$PYTHON_DIAGRAMAS" -m venv "$DIRECTORIO/.venv"
fi
"$DIRECTORIO/.venv/bin/python" -m pip install --disable-pip-version-check \
  -r "$DIRECTORIO/requirements.txt"

if ! command -v dot >/dev/null 2>&1 && [[ ! -x "$DIRECTORIO/.graphviz/usr/bin/dot" ]]; then
  # Alternativa local para Debian/Ubuntu sin contraseña de administrador.
  if ! command -v apt-get >/dev/null 2>&1 || ! command -v dpkg-deb >/dev/null 2>&1; then
    echo 'Instala Graphviz y vuelve a ejecutar este script: https://graphviz.org/download/' >&2
    exit 1
  fi
  mkdir -p "$DIRECTORIO/.graphviz/paquetes"
  (
    cd "$DIRECTORIO/.graphviz/paquetes"
    PAQUETES=(graphviz libgvc6 libcgraph6 libpathplan4 libcdt5 liblab-gamut1)
    if apt-cache show libgts-0.7-5t64 >/dev/null 2>&1; then
      PAQUETES+=(libgts-0.7-5t64)
    else
      PAQUETES+=(libgts-0.7-5)
    fi
    apt-get download "${PAQUETES[@]}"
    for paquete in ./*.deb; do
      dpkg-deb -x "$paquete" "$DIRECTORIO/.graphviz"
    done
  )
fi

exec "$DIRECTORIO/.venv/bin/python" "$DIRECTORIO/generar_diagramas.py"
