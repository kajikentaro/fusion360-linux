#!/bin/bash
set -euo pipefail

export PROTON_USE_WINED3D=0
export DXVK_ASYNC=1
export NO_AT_BRIDGE=1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BROWSER="$SCRIPT_DIR/fusion-browser.sh"
export WINEDLLOVERRIDES="bcp47langs="
# Previous safe-login fallback:
# export WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS="--disable-gpu --no-sandbox"
export WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS="--no-sandbox"
export STEAM_COMPAT_DATA_PATH="$HOME/.fusion360-proton2"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"

PROTON="$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton10-32/proton"
FUSION_ROOT="$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/webdeploy/production"
FUSION_EXE="$(find "$FUSION_ROOT" -maxdepth 2 -name Fusion360.exe | sort | tail -n 1)"

if [[ -z "$FUSION_EXE" ]]; then
  echo "Fusion360.exe was not found under $FUSION_ROOT" >&2
  exit 1
fi

FUSION_DIR="$(dirname "$FUSION_EXE")"
PRODUCTION_CONFIG="$FUSION_DIR/Applications/Fusion/Fusion360App/ApplicationOptions.production.json"
SERVER_CONFIG="$FUSION_DIR/Fusion 360.server.config"

if [[ -f "$PRODUCTION_CONFIG" ]]; then
  cp "$PRODUCTION_CONFIG" "$SERVER_CONFIG"
fi

exec "$PROTON" run "$FUSION_EXE" "$@"
