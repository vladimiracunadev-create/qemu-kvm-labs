#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
need curl; need sha256sum; need qemu-img
IMAGE_URL="${QEMU_CLOUD_IMAGE_URL:-https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img}"
CHECKSUM_URL="${QEMU_CLOUD_IMAGE_SHA256_URL:-https://cloud-images.ubuntu.com/noble/current/SHA256SUMS}"
DEST="$ROOT_DIR/images/ubuntu-24.04-amd64.qcow2"
mkdir -p "$(dirname "$DEST")" "$EVIDENCE_DIR"
if [[ ! -f "$DEST" ]]; then curl --fail --location --output "$DEST.part" "$IMAGE_URL"; mv "$DEST.part" "$DEST"; fi
curl --fail --location --output "$EVIDENCE_DIR/SHA256SUMS" "$CHECKSUM_URL"
EXPECTED="$(awk '/noble-server-cloudimg-amd64.img$/ {print $1}' "$EVIDENCE_DIR/SHA256SUMS")"
[[ -n "$EXPECTED" ]] || die "No se encontró el checksum de la imagen."
ACTUAL="$(sha256sum "$DEST" | awk '{print $1}')"
[[ "$ACTUAL" == "$EXPECTED" ]] || die "Checksum inválido para $DEST"
qemu-img info --output=json "$DEST" >"$EVIDENCE_DIR/cloud-image.json"
log "Imagen verificada: $DEST"
