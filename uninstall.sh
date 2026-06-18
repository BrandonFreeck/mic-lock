#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${HOME}/Library/Application Support/mic-lock"
PLIST_DST="${HOME}/Library/LaunchAgents/local.mic-lock.plist"
LABEL="local.mic-lock"
UID_NUM="$(id -u)"

launchctl bootout "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true
rm -f "${PLIST_DST}"
rm -rf "${INSTALL_DIR}"
rm -f "${HOME}/bin/mic-lock"

echo "Uninstalled ${LABEL}"
