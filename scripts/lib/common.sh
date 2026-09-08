#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_DIR="${QEMU_LABS_STATE:-$ROOT_DIR/state}"
EVIDENCE_DIR="${QEMU_LABS_EVIDENCE:-$ROOT_DIR/evidence/runtime}"
LIBVIRT_URI="${QEMU_LABS_URI:-qemu:///system}"
log() { printf '[qemu-kvm-labs] %s\n' "$*"; }
die() { printf '[qemu-kvm-labs] ERROR: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Falta '$1'. Ejecuta scripts/install.sh."; }
record() { mkdir -p "$EVIDENCE_DIR"; printf '%s\n' "$2" >"$EVIDENCE_DIR/$1"; }
require_linux() { [[ "$(uname -s)" == Linux ]] || die "Este laboratorio requiere Linux. En Windows usa WSL2; macOS solo soporta los labs QEMU/TCG indicados."; }
require_kvm() {
  require_linux
  [[ -e /dev/kvm ]] || die "/dev/kvm no existe. Activa virtualización en firmware y usa un host Linux/WSL2 con KVM anidado."
  [[ -r /dev/kvm && -w /dev/kvm ]] || die "El usuario no puede acceder a /dev/kvm. Añádelo al grupo kvm y abre una sesión nueva."
}
virsh_cmd() { virsh --connect "$LIBVIRT_URI" "$@"; }
