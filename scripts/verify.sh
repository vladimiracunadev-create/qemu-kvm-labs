#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
NAME="${1:-lab-vm}"
need virsh; mkdir -p "$EVIDENCE_DIR"
STATE="$(virsh_cmd domstate "$NAME")"
record "$NAME-state.txt" "$STATE"
[[ "$STATE" == "running" ]] || die "$NAME no está en ejecución: $STATE"
virsh_cmd domifaddr "$NAME" --source agent | tee "$EVIDENCE_DIR/$NAME-addresses.txt"
virsh_cmd domstats "$NAME" --balloon --cpu-total --block | tee "$EVIDENCE_DIR/$NAME-stats.txt"
log "Dominio verificado: $NAME"
