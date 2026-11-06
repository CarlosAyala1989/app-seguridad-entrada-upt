#!/usr/bin/env python3
"""Vista general de tecnologías de IngresoUPT con Diagrams y Graphviz."""

from __future__ import annotations

import base64
import os
from pathlib import Path
import shutil
import subprocess
import xml.etree.ElementTree as ET

from diagrams import Cluster, Diagram, Edge, Node
from diagrams.onprem.database import Mysql
from diagrams.programming.framework import Flutter
from diagrams.programming.language import NodeJS


DIRECTORIO = Path(__file__).resolve().parent
SALIDA = DIRECTORIO / "salida"
NOMBRE = "arquitectura_completa"


def preparar_graphviz() -> None:
    """Usa Graphviz del sistema o la distribución local sin sudo."""
    if not shutil.which("dot"):
        raiz = DIRECTORIO / ".graphviz" / "usr"
        ejecutable = raiz / "bin" / "dot"
        if not ejecutable.exists():
            raise SystemExit("Falta Graphviz. Ejecuta: bash diagramas_arquitectura/generar.sh")
        bibliotecas = next((raiz / "lib").glob("*/graphviz"), None)
        if bibliotecas is None:
            raise SystemExit("La instalación local de Graphviz está incompleta.")
        os.environ["PATH"] = f"{raiz / 'bin'}{os.pathsep}{os.environ.get('PATH', '')}"
        os.environ["LD_LIBRARY_PATH"] = (
            f"{bibliotecas.parent}{os.pathsep}{os.environ.get('LD_LIBRARY_PATH', '')}"
        )
        os.environ["GVBINDIR"] = str(bibliotecas)
        if not (bibliotecas / "config6a").exists():
            subprocess.run([str(ejecutable), "-c"], check=True)
    subprocess.run(["dot", "-V"], check=True)


def grupo(titulo: str, color: str) -> Cluster:
    return Cluster(titulo, graph_attr={
        "fontname": "DejaVu Sans", "fontsize": "17", "fontcolor": "#24445F",
        "style": "rounded,filled", "fillcolor": color, "bgcolor": color,
        "color": "#CBD5E1", "margin": "28",
    })


def generar_diagrama() -> None:
    with Diagram(
        "IngresoUPT | Tecnologías del sistema",
        filename=str(SALIDA / NOMBRE),
        outformat=["png", "svg", "dot"],
        direction="LR", show=False,
        graph_attr={
            "fontname": "DejaVu Sans", "fontsize": "25", "fontcolor": "#142D44",
            "bgcolor": "white", "pad": "0.5", "nodesep": "0.7",
            "ranksep": "1.0", "splines": "spline", "dpi": "150",
            "labelloc": "t", "newrank": "true",
        },
        node_attr={
            "fontname": "DejaVu Sans", "fontsize": "14", "fontcolor": "#243B53",
        },
        edge_attr={
            "fontname": "DejaVu Sans", "fontsize": "12", "fontcolor": "#344D63",
            "color": "#235A91", "penwidth": "1.6", "arrowsize": "0.8",
        },
    ):
        with grupo("Aplicaciones móviles", "#EEF7FD"):
            estudiante = Flutter("Flutter / Dart\nApp estudiante", nodeid="estudiante")
            seguridad = Flutter("Flutter / Dart\nApp seguridad", nodeid="seguridad")

        with grupo("Servidor · Docker / Dokploy", "#F0F8F5"):
            api = NodeJS("Node.js + Express\nAPI REST", nodeid="api")
            bd = Mysql("MySQL / MariaDB\nBase de datos", nodeid="bd")
            api >> Edge(label="SQL") >> bd

        with grupo("Integraciones", "#F7F3FB"):
            atributos = {
                "shape": "box", "style": "rounded,filled", "fillcolor": "white",
                "color": "#B8C4D4", "fixedsize": "false", "width": "2.7",
                "height": "1.0", "margin": "0.2", "labelloc": "c",
            }
            google = Node("Google OAuth 2.0\nIdentidad institucional", nodeid="google", **atributos)
            intranet = Node("Playwright + Chromium\nIntranet UPT", nodeid="intranet", **atributos)

        for aplicacion in (estudiante, seguridad):
            aplicacion >> Edge(label="HTTPS / JSON") >> api
        api >> Edge(label="Autenticación", color="#18786B") >> google
        api >> Edge(label="Verificación", color="#18786B") >> intranet


def incrustar_iconos() -> None:
    """Permite compartir el SVG sin depender de rutas locales del entorno."""
    archivo = SALIDA / f"{NOMBRE}.svg"
    ET.register_namespace("", "http://www.w3.org/2000/svg")
    ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")
    atributo_href = "{http://www.w3.org/1999/xlink}href"
    documento = ET.parse(archivo)
    for elemento in documento.iter("{http://www.w3.org/2000/svg}image"):
        icono = Path(elemento.attrib[atributo_href])
        contenido = base64.b64encode(icono.read_bytes()).decode("ascii")
        elemento.set(atributo_href, f"data:image/png;base64,{contenido}")
    documento.write(archivo, encoding="utf-8", xml_declaration=True)


def main() -> None:
    preparar_graphviz()
    SALIDA.mkdir(parents=True, exist_ok=True)
    generar_diagrama()
    incrustar_iconos()
    for formato in ("png", "svg", "dot"):
        print(f"Generado: {SALIDA / f'{NOMBRE}.{formato}'}")


if __name__ == "__main__":
    main()
