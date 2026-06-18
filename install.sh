#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${HOME}/Library/Application Support/mic-lock"
SCRIPT="${INSTALL_DIR}/lock-mic.sh"
PLIST_SRC="${ROOT}/com.local.mic-lock.plist"
PLIST_DST="${HOME}/Library/LaunchAgents/local.mic-lock.plist"
LABEL="local.mic-lock"
UID_NUM="$(id -u)"
CONFIG="${CONFIG:-${ROOT}/config}"

if [[ ! -f "$CONFIG" ]]; then
	echo "Missing ${CONFIG}. Copy config.example to config and set TARGET_MIC." >&2
	exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG"

TARGET_MIC="${TARGET_MIC:-}"
POLL_SECONDS="${POLL_SECONDS:-15}"
if [[ -z "$TARGET_MIC" ]]; then
	echo "TARGET_MIC is empty in ${CONFIG}" >&2
	exit 1
fi

SAS=""
for candidate in /opt/homebrew/bin/SwitchAudioSource /usr/local/bin/SwitchAudioSource; do
	[[ -x "$candidate" ]] && SAS="$candidate" && break
done
[[ -n "$SAS" ]] || SAS="$(command -v SwitchAudioSource 2>/dev/null || true)"
if [[ -z "$SAS" ]]; then
	echo "SwitchAudioSource not found. Install: brew install switchaudio-osx" >&2
	exit 1
fi

mkdir -p "${INSTALL_DIR}"
cp "${ROOT}/lock-mic.sh" "${SCRIPT}"
chmod +x "${SCRIPT}" "${ROOT}/uninstall.sh"

WRAPPER="${HOME}/bin/mic-lock"
mkdir -p "${HOME}/bin"
cat >"${WRAPPER}" <<EOF
#!/usr/bin/env bash
export TARGET_MIC=$(printf %q "$TARGET_MIC")
exec bash $(printf %q "$SCRIPT")
EOF
chmod +x "${WRAPPER}"

echo "Input devices:"
"$SAS" -t input -a
echo "Current input: $("$SAS" -t input -c)"
echo "Will lock to: ${TARGET_MIC} (every ${POLL_SECONDS}s)"
echo "Installed to: ${INSTALL_DIR} (survives moving/deleting the git clone)"

mkdir -p "${HOME}/Library/LaunchAgents" "${HOME}/Library/Logs"
sed -e "s|__SCRIPT__|${SCRIPT}|g" \
	-e "s|__HOME__|${HOME}|g" \
	-e "s|__TARGET_MIC__|${TARGET_MIC}|g" \
	-e "s|__POLL_SECONDS__|${POLL_SECONDS}|g" \
	"${PLIST_SRC}" >"${PLIST_DST}"

launchctl bootout "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/${UID_NUM}" "${PLIST_DST}"
launchctl enable "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true

echo "Installed ${LABEL} — starts automatically at every login/reboot."
echo "Manual force: mic-lock"
echo "Switch log: ${HOME}/Library/Logs/mic-lock.log"
