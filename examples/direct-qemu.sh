#!/usr/bin/env bash
set -Eeuo pipefail
IMAGE="${1:?uso: $0 DISK.qcow2 [SEED.iso]}"
SEED="${2:-}"
ACCEL="tcg"
[[ -r /dev/kvm && -w /dev/kvm ]] && ACCEL="kvm"
args=(-machine "q35,accel=$ACCEL" -cpu max -m 2048 -smp 2 -drive "file=$IMAGE,if=virtio,format=qcow2" -nic user,model=virtio-net-pci -display none -serial mon:stdio)
[[ -n "$SEED" ]] && args+=(-drive "file=$SEED,media=cdrom,readonly=on")
exec qemu-system-x86_64 "${args[@]}"
