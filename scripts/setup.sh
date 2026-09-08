#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
need python3
python3 -m venv "$ROOT_DIR/.venv"
"$ROOT_DIR/.venv/bin/python" -m pip install --upgrade pip
"$ROOT_DIR/.venv/bin/python" -m pip install -e "$ROOT_DIR"
mkdir -p "$STATE_DIR" "$EVIDENCE_DIR" "$ROOT_DIR/images"
if command -v virsh >/dev/null 2>&1 && ! virsh_cmd net-info default >/dev/null 2>&1; then
  virsh_cmd net-define "$ROOT_DIR/configs/networks/default-nat.xml"
  virsh_cmd net-autostart default
  virsh_cmd net-start default
fi
log "Entorno preparado."
