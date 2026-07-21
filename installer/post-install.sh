#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../ && pwd)"

export STEAM_COMPAT_DATA_PATH="${STEAM_COMPAT_DATA_PATH:-$HOME/.fusion360-proton2}"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_COMPAT_CLIENT_INSTALL_PATH:-$HOME/.local/share/Steam}"

PROTON="${PROTON:-$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton10-32/proton}"
BACKGROUND="$SCRIPT_DIR/background.sh"
FUSION_BROWSER="$SCRIPT_DIR/fusion-browser.sh"

DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/fusion360-adskidmgr.desktop"

[[ -x "$PROTON" ]] || {
  echo "Proton not found: $PROTON" >&2
  exit 1
}

[[ -f "$BACKGROUND" ]] || {
  echo "background.sh not found: $BACKGROUND" >&2
  exit 1
}

[[ -f "$FUSION_BROWSER" ]] || {
  echo "fusion-browser.sh not found: $FUSION_BROWSER" >&2
  exit 1
}

chmod +x "$BACKGROUND"
chmod +x "$FUSION_BROWSER"

# フォールバックさせず、fusion-browser.shだけを使用する
"$PROTON" run reg.exe add \
  'HKCU\Software\Wine\WineBrowser' \
  /v Browsers \
  /t REG_SZ \
  /d "\"/bin/bash\" \"$FUSION_BROWSER\"" \
  /f

for SCHEME in http https; do
  "$PROTON" run reg.exe add \
    "HKCU\\Software\\Classes\\${SCHEME}\\shell\\open\\command" \
    /ve \
    /t REG_SZ \
    /d '"C:\windows\system32\winebrowser.exe" -nohome "%1"' \
    /f
done

mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Fusion 360 Autodesk Login
Exec="$BACKGROUND" --callback %u
NoDisplay=true
Terminal=false
StartupNotify=false
MimeType=x-scheme-handler/adskidmgr;x-scheme-handler/adsk.idmgr;
EOF

chmod 644 "$DESKTOP_FILE"

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$DESKTOP_FILE"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR"
fi

xdg-mime default \
  "$(basename "$DESKTOP_FILE")" \
  x-scheme-handler/adskidmgr

xdg-mime default \
  "$(basename "$DESKTOP_FILE")" \
  x-scheme-handler/adsk.idmgr

echo
echo "Configuration completed."
echo
echo "adskidmgr:"
xdg-mime query default x-scheme-handler/adskidmgr
echo
echo "adsk.idmgr:"
xdg-mime query default x-scheme-handler/adsk.idmgr