#!/usr/bin/env bash
# Switch the Mark II venv from floating installer-alpha to this snapshot.
# Does not reinstall packages. Does not run ovos-installer.
set -euo pipefail

HOST="${1:-clinton@mycroft-prime.lan}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ssh -o BatchMode=yes "$HOST" 'mkdir -p ~/.venvs/ovos ~/.config/pip ~/.config/ovos-mark2 ~/.config/ovos-installer'

scp -o BatchMode=yes "$ROOT/pins/constraints.txt" "$HOST:~/.venvs/ovos/constraints.txt"
scp -o BatchMode=yes "$ROOT/overlay/pip/pip.conf" "$HOST:~/.config/pip/pip.conf"

# Overlay mycroft.conf (no secrets in this file). Backup first.
ssh -o BatchMode=yes "$HOST" 'cp -n ~/.config/mycroft/mycroft.conf ~/.config/mycroft/mycroft.conf.bak-pre-mark2 || true'
scp -o BatchMode=yes "$ROOT/overlay/mycroft.conf" "$HOST:~/.config/mycroft/mycroft.conf"

ssh -o BatchMode=yes "$HOST" "cat > ~/.config/ovos-mark2/OWNED_BY <<EOF
owned-by: github.com/clintonthegeek/ovos-mark2
snapshot: 2026-09-05
venv: ~/.venvs/ovos
constraints: ~/.venvs/ovos/constraints.txt
do-not-run: ovos-installer
do-not: pip install -U ovos-*
EOF
cat > ~/.config/ovos-installer/DO_NOT_RUN <<EOF
This device is owned by ovos-mark2 (pinned snapshot).
Running ovos-installer will overwrite configs, units, and the venv.
EOF
"

# Prove pip is constrained: a newer ovos-core must be rejected.
ssh -o BatchMode=yes "$HOST" '
echo "=== pip.conf ==="
cat ~/.config/pip/pip.conf
echo "=== constraint head ==="
head -8 ~/.venvs/ovos/constraints.txt
echo "=== dry-run newer ovos-core (must fail or no-op) ==="
~/.venvs/ovos/bin/pip install --dry-run "ovos-core==99.0.0" && echo UNEXPECTED_SUCCESS || echo "constraint held (expected fail)"
echo "=== current ovos-core ==="
~/.venvs/ovos/bin/pip show ovos-core | grep -E "^(Name|Version)"
'

echo "Pinned $HOST to ovos-mark2 snapshot."
echo "Restart ovos-core if you want the mycroft.conf installer flags to take effect:"
echo "  ssh $HOST sudo systemctl restart ovos-core.service"
