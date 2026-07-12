#!/bin/bash
# set -euo pipefail

export PROTON_USE_WINED3D=0
export DXVK_ASYNC=1
export NO_AT_BRIDGE=1
export WINEDLLOVERRIDES="bcp47langs="
# Previous safe-login fallback:
# export WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS="--disable-gpu --no-sandbox"
export WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS="--no-sandbox"
export STEAM_COMPAT_DATA_PATH="$HOME/.fusion360-proton2"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"

PROTON="$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton10-32/proton"
FUSION_ROOT="$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/webdeploy/production"
INSTALLER_EXT="$HOME/Downloads/FusionClientDownloader.exe"

if [[ ! -e "$INSTALLER_EXT" ]]; then
  echo "Downloading installer"
  curl -L -o $INSTALLER_EXT "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20360%20Client%20Downloader.exe"
fi

exec "$PROTON" run "$INSTALLER_EXT" "$@"
