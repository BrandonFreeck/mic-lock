#!/usr/bin/env bash
# Called by launchd on an interval. No loop — exit fast when already correct or target absent.
set -euo pipefail

TARGET_MIC="${TARGET_MIC:?TARGET_MIC not set}"
LOG_FILE="${HOME}/Library/Logs/mic-lock.log"

# launchd PATH is often just /usr/bin:/bin — find Homebrew explicitly.
SAS=""
for candidate in /opt/homebrew/bin/SwitchAudioSource /usr/local/bin/SwitchAudioSource; do
	[[ -x "$candidate" ]] && SAS="$candidate" && break
done
[[ -n "$SAS" ]] || SAS="$(command -v SwitchAudioSource 2>/dev/null || true)"
[[ -n "$SAS" ]] || exit 0

if ! "$SAS" -t input -a 2>/dev/null | grep -Fxq "$TARGET_MIC"; then
	exit 0
fi

current="$("$SAS" -t input -c 2>/dev/null || true)"
[[ "$current" == "$TARGET_MIC" ]] && exit 0

"$SAS" -t input -s "$TARGET_MIC"
printf '%s switched input to %q (was: %q)\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$TARGET_MIC" "${current:-unknown}" >>"$LOG_FILE"
