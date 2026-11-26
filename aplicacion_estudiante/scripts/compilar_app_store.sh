#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"
release_config="${1:-config/app_store.json}"
if [ "$#" -gt 0 ]; then shift; fi

python3 scripts/verificar_app_store.py --config "$release_config"
if [ "$(uname -s)" != "Darwin" ]; then
  echo "La compilación iOS requiere un Mac con Xcode 26 o posterior." >&2
  exit 1
fi
xcode_version="$(xcodebuild -version | head -n 1 | awk '{print $2}')"
ios_sdk_version="$(xcrun --sdk iphoneos --show-sdk-version)"
if [ "${xcode_version%%.*}" -lt 26 ] || [ "${ios_sdk_version%%.*}" -lt 26 ]; then
  echo "Selecciona Xcode 26 o posterior con SDK iOS 26 o posterior." >&2
  exit 1
fi

flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build ipa --release --dart-define-from-file="$release_config" "$@"
python3 scripts/verificar_app_store.py --config "$release_config" \
  --app build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
echo "IPA generada. Valida el archivo y pruébalo en TestFlight antes del envío."
