#!/usr/bin/env python3
"""Comprobaciones locales. No publica ni certifica aprobación de App Review."""

import argparse
import json
import plistlib
import re
import struct
import sys
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
DATA_TYPES = {
    "Name", "EmailAddress", "UserID", "DeviceID", "PreciseLocation",
    "PhotosorVideos", "OtherDataTypes",
}


def read_plist(path):
    with path.open("rb") as stream:
        return plistlib.load(stream)


def check_source(errors):
    runner = ROOT / "ios/Runner"
    info = read_plist(runner / "Info.plist")
    for key in ("NSFaceIDUsageDescription", "NSLocationWhenInUseUsageDescription"):
        if len(info.get(key, "").strip()) < 40:
            errors.append(f"Falta una explicación concreta para {key}.")
    if "location" in info.get("UIBackgroundModes", []):
        errors.append("La app de estudiante no debe solicitar ubicación en segundo plano.")
    for key in ("NSLocationAlwaysUsageDescription", "NSLocationAlwaysAndWhenInUseUsageDescription"):
        if key in info:
            errors.append(f"Permiso innecesario: {key}.")
    if info.get("NSAppTransportSecurity", {}).get("NSAllowsArbitraryLoads"):
        errors.append("App Transport Security permite conexiones inseguras.")

    privacy = read_plist(runner / "PrivacyInfo.xcprivacy")
    if privacy.get("NSPrivacyTracking") is not False or privacy.get("NSPrivacyTrackingDomains"):
        errors.append("La declaración de tracking no coincide con esta app sin publicidad.")
    entries = privacy.get("NSPrivacyCollectedDataTypes", [])
    declared = {entry["NSPrivacyCollectedDataType"].removeprefix("NSPrivacyCollectedDataType") for entry in entries}
    if declared != DATA_TYPES:
        errors.append("Revisar los tipos de datos del manifiesto frente al inventario de privacidad.")
    for entry in entries:
        if (entry.get("NSPrivacyCollectedDataTypeLinked") is not True
                or entry.get("NSPrivacyCollectedDataTypeTracking") is not False
                or entry.get("NSPrivacyCollectedDataTypePurposes") != ["NSPrivacyCollectedDataTypePurposeAppFunctionality"]):
            errors.append("Declaración de datos incompatible con el uso institucional documentado.")

    project = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
    resources = project.split("97C146EC1CF9000F007C117D /* Resources */ = {", 1)[1].split("};", 1)[0]
    if "PrivacyInfo.xcprivacy in Resources" not in resources:
        errors.append("El manifiesto no está incluido en los recursos de Runner.")
    if "com.example." in project:
        errors.append("El Bundle ID conserva el identificador de ejemplo.")
    if project.count("CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;") != 3:
        errors.append("Configurar los entitlements en Debug, Profile y Release.")
    read_plist(runner / "Runner.entitlements")
    podfile = (ROOT / "ios/Podfile").read_text()
    if "BYPASS_PERMISSION_LOCATION_ALWAYS=1" not in podfile:
        errors.append("Falta desactivar la solicitud Always de geolocator_apple.")
    for mode in ("Debug", "Profile", "Release"):
        xcconfig = (ROOT / f"ios/Flutter/{mode}.xcconfig").read_text()
        if f"Pods-Runner.{mode.lower()}.xcconfig" not in xcconfig:
            errors.append(f"Falta la configuración de CocoaPods en {mode}.")

    icons_path = runner / "Assets.xcassets/AppIcon.appiconset"
    icons = json.loads((icons_path / "Contents.json").read_text())
    marketing_icon = False
    for icon in icons["images"]:
        filename = icon.get("filename")
        if not filename:
            errors.append("Hay un tamaño de icono sin archivo asignado.")
            continue
        raw = (icons_path / filename).read_bytes()
        if raw[:8] != b"\x89PNG\r\n\x1a\n":
            errors.append(f"Icono inválido: {filename}.")
            continue
        width, height, _, color_type = struct.unpack(">IIBB", raw[16:26])
        # RGB o escala de grises sin transparencia, incluida la de una paleta.
        if color_type not in (0, 2) or b"tRNS" in raw:
            errors.append(f"Eliminar el canal alfa del icono {filename}.")
        size = int(float(icon["size"].split("x")[0]) * int(icon["scale"].rstrip("x")))
        if (width, height) != (size, size):
            errors.append(f"Dimensiones incorrectas: {filename}.")
        if icon.get("idiom") == "ios-marketing" and size == 1024:
            marketing_icon = True
    if not marketing_icon:
        errors.append("Falta el icono de App Store de 1024 × 1024.")


def public_url(value):
    if not isinstance(value, str) or value != value.strip():
        return False
    try:
        url = urlsplit(value)
        host = url.hostname or ""
        return (url.scheme == "https" and "." in host
                and not url.username and not url.password
                and host not in ("127.0.0.1", "0.0.0.0")
                and not host.endswith((".local", ".localhost", ".invalid", ".example", ".test"))
                and host not in ("example.com", "example.org", "example.net")
                and url.port in (None, 443))
    except ValueError:
        return False


def check_config(path, errors):
    config = json.loads(path.read_text())
    if not isinstance(config, dict):
        errors.append("La configuración debe ser un objeto JSON.")
        return
    keys = ("URL_API_UPT", "URL_PRIVACIDAD_UPT", "URL_SOPORTE_UPT", "URL_ELIMINAR_CUENTA_UPT")
    for key in keys:
        if not public_url(config.get(key)):
            errors.append(f"Completar {key} con una URL HTTPS pública real.")
    deletion = config.get("URL_ELIMINAR_CUENTA_UPT", "")
    if isinstance(deletion, str) and deletion:
        if urlsplit(deletion).path in ("", "/"):
            errors.append("La URL de eliminación debe llevar directamente al proceso de eliminación.")
        if deletion in (config.get("URL_PRIVACIDAD_UPT"), config.get("URL_SOPORTE_UPT")):
            errors.append("La eliminación necesita una página específica, distinta de privacidad y soporte.")
    if str(config.get("UBICACION_SIMULADA", "false")).lower() != "false":
        errors.append("No incluir ubicación simulada en la configuración de distribución.")


def check_archive(path, errors):
    # --app recibe Runner.app dentro del .xcarchive, no una compilación simulator.
    info = read_plist(path / "Info.plist")
    sdk = re.fullmatch(r"iphoneos(\d+)(?:\.\d+)*", info.get("DTSDKName", ""))
    if not sdk or int(sdk[1]) < 26:
        errors.append("El archivo debe compilarse con el SDK iOS 26 o posterior.")
    if int(info.get("DTXcode", "0")) < 2600:
        errors.append("El archivo debe compilarse con Xcode 26 o posterior.")
    if "com.example." in info.get("CFBundleIdentifier", "com.example.missing"):
        errors.append("El archivo conserva un Bundle ID de ejemplo.")
    read_plist(path / "PrivacyInfo.xcprivacy")
    for manifest in path.rglob("PrivacyInfo.xcprivacy"):
        read_plist(manifest)
    if not list(path.glob("Frameworks/Flutter.framework/**/PrivacyInfo.xcprivacy")):
        errors.append("No se encontró el manifiesto de Flutter en el archivo; revisar el SDK y sus recursos.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-only", action="store_true", help="Valida solo el código fuente; no habilita publicación.")
    parser.add_argument("--config", type=Path, default=ROOT / "config/app_store.json")
    parser.add_argument("--app", type=Path, help="Ruta a Runner.app dentro del archivo de distribución.")
    args = parser.parse_args()
    errors = []
    try:
        check_source(errors)
        if not args.source_only:
            check_config(args.config, errors)
        if args.app:
            check_archive(args.app, errors)
    except (OSError, ValueError, KeyError, IndexError, TypeError, plistlib.InvalidFileException) as error:
        errors.append(f"No se pudo comprobar la configuración: {error}")
    if errors:
        print("Pendientes antes de publicar:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("Comprobaciones de código fuente correctas." if args.source_only else "Comprobaciones locales correctas.")
    print("Falta la validación funcional, legal, de firma y de App Store Connect descrita en docs/app_store/PUBLICACION.md.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
