#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
need cloud-localds
NAME="${1:-lab-vm}"
SSH_KEY="${QEMU_LABS_SSH_PUBLIC_KEY:-$HOME/.ssh/id_ed25519.pub}"
[[ -f "$SSH_KEY" ]] || die "No existe la clave pública $SSH_KEY. Define QEMU_LABS_SSH_PUBLIC_KEY."
mkdir -p "$STATE_DIR/cloud-init/$NAME"
sed "s|__SSH_PUBLIC_KEY__|$(cat "$SSH_KEY")|g; s|__HOSTNAME__|$NAME|g" "$ROOT_DIR/configs/cloud-init/user-data" >"$STATE_DIR/cloud-init/$NAME/user-data"
sed "s|__HOSTNAME__|$NAME|g" "$ROOT_DIR/configs/cloud-init/meta-data" >"$STATE_DIR/cloud-init/$NAME/meta-data"
cloud-localds "$STATE_DIR/$NAME-seed.iso" "$STATE_DIR/cloud-init/$NAME/user-data" "$STATE_DIR/cloud-init/$NAME/meta-data"
log "Seed creado: $STATE_DIR/$NAME-seed.iso"
