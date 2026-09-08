#!/usr/bin/env bash
set -Eeuo pipefail
[[ "$(uname -s)" == Linux ]] || { echo "ERROR: usa Linux o WSL2." >&2; exit 1; }
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virtinst cloud-image-utils genisoimage ovmf python3 python3-venv
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y @virtualization qemu-img libvirt-client virt-install cloud-utils-growpart genisoimage edk2-ovmf python3
else
  echo "ERROR: distribución no automatizada. Instala QEMU, libvirt, virt-install, cloud-image-utils, OVMF y Python 3.11+." >&2
  exit 1
fi
sudo systemctl enable --now libvirtd 2>/dev/null || sudo systemctl enable --now virtqemud.socket
sudo usermod -aG kvm,libvirt "$USER"
echo "Instalación terminada. Abre una sesión nueva para aplicar los grupos kvm/libvirt."
