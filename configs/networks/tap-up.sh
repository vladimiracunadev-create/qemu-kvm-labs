#!/usr/bin/env bash
set -Eeuo pipefail
TAP_NAME="${1:-tap-qemu-lab}"
BRIDGE="${QEMU_LABS_BRIDGE:-br0}"
sudo ip tuntap add dev "$TAP_NAME" mode tap user "$USER" 2>/dev/null || true
sudo ip link set "$TAP_NAME" master "$BRIDGE"
sudo ip link set "$TAP_NAME" up
