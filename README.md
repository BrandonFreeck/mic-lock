# mic-lock

Pin macOS system default **microphone input** to the device you choose.

macOS switches your input when you connect headphones, AirPods, USB gear, etc. Apps that only follow system default (many voice/PTT tools) then grab the wrong mic. This runs a shell script on an interval via `launchd` and switches back when something else took over.

No app. No menu bar. `./install.sh` once.

---

## Quick install (human or agent)

**Prerequisites:** macOS, [Homebrew](https://brew.sh/), [switchaudio-osx](https://github.com/deweller/switchaudio-osx).

```bash
brew install switchaudio-osx
git clone https://github.com/BrandonFreeck/mic-lock.git
cd mic-lock
cp config.example config
```

List input devices and pick the exact name (casing matters):

```bash
SwitchAudioSource -t input -a
SwitchAudioSource -t input -c   # current default
```

Edit `config` — set `TARGET_MIC` to that exact string. Common picks:

| Goal | Typical `TARGET_MIC` |
|------|----------------------|
| Block BT headset mic, use laptop mic | `MacBook Pro Microphone` or `Built-in Microphone` |
| Pin a USB desk mic | e.g. `HyperX SoloCast` |
| Pin a virtual/audio app mic | exact name from `-a` list |

Install (persists across reboots; no Login Items needed):

```bash
./install.sh
```

Done. Re-run `./install.sh` only if you change `config`.

**Uninstall:** `./uninstall.sh`

**Force now (skip poll wait):** `mic-lock` (installed to `~/bin`)

---

## Config

Copy `config.example` → `config` (gitignored).

| Variable | Default | Meaning |
|----------|---------|---------|
| `TARGET_MIC` | *(required)* | Exact input device name from `SwitchAudioSource -t input -a` |
| `POLL_SECONDS` | `15` | Seconds between checks |

---

## Persistence

- LaunchAgent: `local.mic-lock` in `~/Library/LaunchAgents/`
- Loads automatically at every login/reboot
- `RunAtLoad` — enforce once immediately; then every `POLL_SECONDS`
- Script copied to `~/Library/Application Support/mic-lock/` — safe to delete the git clone after install

---

## Logs

| File | When |
|------|------|
| `~/Library/Logs/mic-lock.log` | Only when input was switched |
| `~/Library/Logs/mic-lock.launchd.log` | launchd stderr |

---

## Limitations

- Apps with an **already-open mic stream** may not switch until they reopen the mic.
- **Poll delay** — up to `POLL_SECONDS` before correction; use `mic-lock` for immediate.
- **Target must exist** — if the device isn't available, script exits quietly (no error loop).
- **Exact name** — must match `SwitchAudioSource -t input -a` output exactly.

---

## How it works

1. `lock-mic.sh` resolves `SwitchAudioSource` (Homebrew paths included — launchd PATH is minimal).
2. If `TARGET_MIC` not in device list → exit 0.
3. If current input ≠ target → switch + one log line.
4. `install.sh` copies script to Application Support and registers the LaunchAgent.

---

## License

MIT
