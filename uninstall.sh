#!/usr/bin/env bash
set -euo pipefail

PLIST_DST="${HOME}/Library/LaunchAgents/local.mic-lock.plist"
LABEL="local.mic-lock"
UID_NUM="$(id -u)"

launchctl bootout "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true
rm -f "${PLIST_DST}"

echo "Uninstalled ${LABEL}"
