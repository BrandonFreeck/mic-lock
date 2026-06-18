# mic-lock

Dumb macOS script that keeps your system default **input** on the microphone you pick.

macOS loves switching your mic when you plug in headphones, connect AirPods, or wake from sleep. Some apps only follow system default. This runs a tiny shell script every N seconds via `launchd` and switches back if something else took over.

No app. No menu bar. One script and a plist.

## Requirements

- macOS
- [Homebrew](https://brew.sh/)
- [switchaudio-osx](https://github.com/deweller/switchaudio-osx):

```bash
brew install switchaudio-osx
```

## Install

```bash
git clone https://github.com/BrandonFreeck/mic-lock.git
cd mic-lock
cp config.example config
```

Edit `config` — set `TARGET_MIC` to the **exact** name from:

```bash
SwitchAudioSource -t input -a
```

Examples people use this for:

- `Built-in Microphone` — block Bluetooth headset mics
- `krisp microphone` — keep Krisp virtual mic as system default
- Any USB mic you want pinned

Then:

```bash
./install.sh
```

That registers a LaunchAgent (`local.mic-lock`) and puts a `mic-lock` command in `~/bin` for instant manual enforcement.

**Persists across reboots.** The agent plist lives in `~/Library/LaunchAgents/` — macOS loads it automatically every time you log in. `RunAtLoad` enforces once immediately; then every `POLL_SECONDS`. Install copies the script to `~/Library/Application Support/mic-lock/` so you can move or delete the git clone and it keeps working.

Fire once: `./install.sh` and you're done unless you change `TARGET_MIC` (re-run install after editing `config`).

## Uninstall

```bash
./uninstall.sh
```

## Config

| Variable | Default | Meaning |
|----------|---------|---------|
| `TARGET_MIC` | *(required)* | Exact input device name |
| `POLL_SECONDS` | `15` | How often to check and fix |

`config` is gitignored — your machine, your mic name.

## Logs

| File | When it writes |
|------|----------------|
| `~/Library/Logs/mic-lock.log` | Only when it actually switched input |
| `~/Library/Logs/mic-lock.launchd.log` | launchd stderr (errors) |

## Manual force

Don't want to wait for the next poll?

```bash
mic-lock
```

## Limitations

- **Apps already recording** may keep the wrong device until they reopen the mic stream.
- **Poll delay** — default 15s between checks. Lower `POLL_SECONDS` if you care; raise it if you don't.
- **Target must exist** — if your mic isn't connected (or Krisp isn't running), the script exits quietly and does nothing.
- **Exact name match** — copy/paste from `SwitchAudioSource -t input -a`; casing matters.

## How it works

1. `lock-mic.sh` finds `SwitchAudioSource` (including Homebrew paths launchd doesn't have on PATH).
2. If `TARGET_MIC` isn't in the device list, exit.
3. If current input ≠ target, switch and append one line to the log.
4. `install.sh` copies the script to `~/Library/Application Support/mic-lock/` and registers a LaunchAgent plist (auto-starts at login).

That's it.

## License

MIT
