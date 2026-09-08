#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
NAME="${1:-lab-vm}"
virsh_cmd shutdown "$NAME"
for _ in {1..30}; do
  [[ "$(virsh_cmd domstate "$NAME" 2>/dev/null || true)" == "shut off" ]] && { log "$NAME detenido."; exit 0; }
  sleep 1
done
die "$NAME no se detuvo en 30 s. Usa: virsh --connect $LIBVIRT_URI destroy $NAME"
