#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
NAME="${1:-lab-vm}"
BASE="${2:-$ROOT_DIR/images/ubuntu-24.04-amd64.qcow2}"
require_kvm; need vm-manager
[[ -f "$STATE_DIR/$NAME-seed.iso" ]] || "$ROOT_DIR/scripts/create-cloud-init.sh" "$NAME"
vm-manager --state-dir "$STATE_DIR" --uri "$LIBVIRT_URI" create "$NAME" --base-image "$BASE" --cloud-init "$STATE_DIR/$NAME-seed.iso"
vm-manager --state-dir "$STATE_DIR" --uri "$LIBVIRT_URI" start "$NAME"
