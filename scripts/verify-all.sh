#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
mkdir -p "$EVIDENCE_DIR"
"$ROOT_DIR/scripts/test.sh"
python3 "$ROOT_DIR/scripts/validate-repo.py"
if [[ "$(uname -s)" == Linux ]] && [[ -r /dev/kvm && -w /dev/kvm ]] && command -v virsh >/dev/null 2>&1; then
  "$ROOT_DIR/scripts/check-host.sh"
  virsh_cmd list --all | tee "$EVIDENCE_DIR/domains.txt"
else
  record "hardware-skipped.txt" "KVM/libvirt runtime checks skipped: host lacks accessible /dev/kvm or virsh."
  log "SKIP explícito: verificaciones runtime KVM no compatibles con este host."
fi
log "Verificaciones compatibles completadas. Evidencia: $EVIDENCE_DIR"
