#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
mkdir -p "$EVIDENCE_DIR"
python3 - <<'PY' >"$EVIDENCE_DIR/host.json"
import json, os, platform, shutil
print(json.dumps({
  "platform": platform.platform(), "machine": platform.machine(), "python": platform.python_version(),
  "commands": {x: shutil.which(x) for x in ("qemu-system-x86_64", "qemu-img", "virsh", "virt-install", "cloud-localds")},
  "dev_kvm": {"exists": os.path.exists("/dev/kvm"), "readable": os.access("/dev/kvm", os.R_OK), "writable": os.access("/dev/kvm", os.W_OK)}
}, indent=2))
PY
cat "$EVIDENCE_DIR/host.json"
require_linux
for command in qemu-system-x86_64 qemu-img virsh; do need "$command"; done
grep -Eq '(vmx|svm)' /proc/cpuinfo || die "La CPU no expone vmx/svm al sistema invitado."
require_kvm
virsh_cmd version | tee "$EVIDENCE_DIR/libvirt-version.txt"
qemu-system-x86_64 --version | head -n 1 | tee "$EVIDENCE_DIR/qemu-version.txt"
log "Host compatible con los laboratorios KVM."
