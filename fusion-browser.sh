#!/bin/bash
set -Eeuo pipefail

PIPE="/tmp/fusion-browser-${UID}.pipe"
PID_FILE="/tmp/fusion-browser-${UID}.pid"
LOG="/tmp/fusion-browser-${UID}.log"

log() {
  printf '%(%Y-%m-%dT%H:%M:%S%z)T %s\n' -1 "$*" >> "$LOG"
}

die() {
  log "ERROR: $*"
  printf '%s\n' "$*" >&2
  exit 1
}

URL=""

for ARG in "$@"; do
  if [[ "$ARG" =~ ^https?:// ]]; then
    URL="$ARG"
    break
  fi
done

[[ -n "$URL" ]] ||
  die "HTTP/HTTPS URL not found"

[[ -p "$PIPE" ]] ||
  die "background.sh is not running: FIFO not found"

[[ -r "$PID_FILE" ]] ||
  die "background.sh is not running: PID file not found"

IFS= read -r LISTENER_PID < "$PID_FILE" ||
  die "Failed to read listener PID"

[[ "$LISTENER_PID" =~ ^[0-9]+$ ]] ||
  die "Invalid listener PID"

kill -0 "$LISTENER_PID" 2>/dev/null ||
  die "background.sh is not running"

log "HTTP URL received from WineBrowser"

printf '%s\n' "$URL" > "$PIPE" ||
  die "Failed to write URL to FIFO"