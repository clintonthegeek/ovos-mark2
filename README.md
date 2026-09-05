# ovos-mark2

Clinton's frozen Mycroft Mark II stack. Not an OVOS installer. Not a fork of `ovos-core`.

The live box (`clinton@mycroft-prime.lan`) was installed with `ovos-installer` `main` @ `ed0421e` on Raspberry Pi OS Trixie Lite, then patched by hand. Upstream is moving too fast to track. This repo **owns that snapshot** and the hardware/config we will rewrite.

## What this is

| Layer | How we own it |
|---|---|
| Python venv `~/.venvs/ovos` | Exact `pins/constraints.txt` (ovos-core **2.2.4a1** and friends). pip on the Pi must not float. |
| SJ-201 / XMOS / TAS5806 | Files under `hardware/` + `overlay/systemd/user/sj201.service` |
| `mycroft.conf` overlay | `overlay/mycroft.conf` |
| VocalFusion dtoverlay | Fork [clintonthegeek/VocalFusionDriver](https://github.com/clintonthegeek/VocalFusionDriver) branch `mark2` (MCLK 12.288 MHz) |

We do **not** re-run `ovos-installer`. We do **not** `pip install -U ovos-*`. Fixes land here (or in a tiny fork of a single package) and get rsynced to the Pi.

## Snapshot (2026-09-05)

- Pi 4B 2 GB + SJ-201, Trixie Lite 64-bit
- Python 3.11.16
- TTS: Piper `alan-low`
- STT: Vosk `vosk-model-small-en-us-0.15` (Faster-Whisper `tiny` hangs with GUI)
- Wake word: precise-onnx `hey_mycroft`
- Known still-broken: XMOS I2S capture is digital silence (`Sending complete` ≠ DSP running). See `../docs/mark-ii-bringup/UPSTREAM.md`.

## Apply the pin on the Pi (one-time switch off installer alpha)

From this laptop:

```bash
./scripts/pin-pi.sh clinton@mycroft-prime.lan
```

That copies `constraints.txt` into the venv, installs a user pip constraint, turns off skill `allow_pip` / `allow_alphas`, and writes `~/.config/ovos-mark2/OWNED_BY`. After that, `pip install ovos-core` without a matching pin fails.

## Rules

1. Never run the OVOS installer on the Pi again.
2. Never `pip install -U` in `~/.venvs/ovos`.
3. New Python patches: fork the **one** package, pin that SHA in `pins/overrides.txt`, `pip install` that exact git ref with `--constraint pins/constraints.txt`.
4. Hardware patches: edit `hardware/`, rsync `/opt/sj201`, bounce `sj201.service`.
