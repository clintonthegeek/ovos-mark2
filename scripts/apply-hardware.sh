#!/usr/bin/env bash
# Rsync SJ-201 userspace files we own. Does not flash; bounce sj201.service after.
set -euo pipefail
HOST="${1:-clinton@mycroft-prime.lan}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ssh -o BatchMode=yes "$HOST" 'mkdir -p /tmp/ovos-mark2-hw /opt/sj201'
scp -o BatchMode=yes \
  "$ROOT/hardware/init_tas5806.py" \
  "$ROOT/hardware/xvf3510-flash" \
  "$HOST:/tmp/ovos-mark2-hw/"
ssh -o BatchMode=yes "$HOST" '
install -m 0755 /tmp/ovos-mark2-hw/init_tas5806.py /opt/sj201/init_tas5806_fixed.py
install -m 0755 /tmp/ovos-mark2-hw/xvf3510-flash /opt/sj201/xvf3510-flash
'
scp -o BatchMode=yes "$ROOT/overlay/systemd/user/sj201.service" \
  "$HOST:~/.config/systemd/user/sj201.service"
ssh -o BatchMode=yes "$HOST" 'systemctl --user daemon-reload'
echo "Hardware files installed. To reflash: ssh $HOST systemctl --user restart sj201.service"
