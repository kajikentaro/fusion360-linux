#!/usr/bin/env bash
set -Eeuo pipefail

export STEAM_COMPAT_DATA_PATH="${STEAM_COMPAT_DATA_PATH:-$HOME/.fusion360-proton2}"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_COMPAT_CLIENT_INSTALL_PATH:-$HOME/.local/share/Steam}"

PROTON="${PROTON:-$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton10-32/proton}"
CHROME="${CHROME:-/usr/bin/google-chrome}"

PIPE="/tmp/fusion-browser-${UID}.pipe"
PID_FILE="/tmp/fusion-browser-${UID}.pid"
LOCK_FILE="/tmp/fusion-browser-${UID}.lock"
LOG="/tmp/fusion-browser-${UID}.log"

log() {
  printf '%(%Y-%m-%dT%H:%M:%S%z)T %s\n' -1 "$*" >> "$LOG"
}

die() {
  log "ERROR: $*"
  printf '%s\n' "$*" >&2
  exit 1
}

#
# ChromeからAutodesk callback URIを受け取る
#
if [[ "${1:-}" == "--callback" ]]; then
  URI="${2:-}"

  [[ "$URI" == adskidmgr:* || "$URI" == adsk.idmgr:* ]] ||
    die "Unsupported callback URI"

  IDM_EXE="$(
    find "$STEAM_COMPAT_DATA_PATH/pfx" \
      -type f \
      -iname 'AdskIdentityManager.exe' \
      -printf '%T@ %p\n' 2>/dev/null |
      sort -nr |
      head -n 1 |
      cut -d' ' -f2-
  )"

  [[ -n "$IDM_EXE" ]] ||
    die "AdskIdentityManager.exe not found"

  log "Callback received; launching Autodesk Identity Manager"

  exec "$PROTON" run "$IDM_EXE" "$URI"
fi

#
# 引数なしの場合はFIFO待機
#
if (( $# > 0 )); then
  die "Unknown arguments"
fi

exec 8>"$LOCK_FILE"

if ! flock -n 8; then
  die "background.sh is already running"
fi

cleanup() {
  rm -f "$PIPE" "$PID_FILE"
  log "Listener stopped"
}

trap cleanup EXIT INT TERM

rm -f "$PIPE" "$PID_FILE"

mkfifo -m 600 "$PIPE"
printf '%s\n' "$$" > "$PID_FILE"

log "Listener started on $PIPE"

printf 'Waiting on %s\n' "$PIPE"
printf 'Log: %s\n' "$LOG"

exec 9<>"$PIPE"

while IFS= read -r URL <&9; do
  if [[ "$URL" =~ ^https?:// ]]; then
    log "Opening host Chrome"

    "$CHROME" --new-window "$URL" \
      >> "$LOG" 2>&1 &
  else
    log "Ignored invalid URL"
  fi
done