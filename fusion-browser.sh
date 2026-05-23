#!/bin/bash
set -euo pipefail
printf "%s\n" "$(date -Is) $*" >> /tmp/fusion-browser.log
exec /usr/bin/google-chrome --new-window "$@"
