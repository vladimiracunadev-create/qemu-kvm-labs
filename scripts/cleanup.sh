#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
TARGET="${1:-lab-vm}"
if [[ "$TARGET" == "--all" ]]; then
  [[ -f "$STATE_DIR/registry.json" ]] || { log "No hay VMs administradas."; exit 0; }
  mapfile -t NAMES < <(python3 -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))))' "$STATE_DIR/registry.json")
else NAMES=("$TARGET"); fi
for name in "${NAMES[@]}"; do
  vm-manager --state-dir "$STATE_DIR" --uri "$LIBVIRT_URI" delete "$name" --force
  rm -f "$STATE_DIR/$name-seed.iso"
done
log "Recursos administrados eliminados. Las imágenes base se conservaron."
