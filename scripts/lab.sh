#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
ACTION="${1:?uso: $0 LAB_ID run|verify}"
MODE="${2:?uso: $0 LAB_ID run|verify}"
NAME="${QEMU_LABS_VM:-lab-vm}"
mkdir -p "$EVIDENCE_DIR/lab-$ACTION"
OUT="$EVIDENCE_DIR/lab-$ACTION/$MODE.txt"
case "$ACTION:$MODE" in
  01:run) exec "$ROOT_DIR/scripts/check-host.sh" ;;
  01:verify) test -r /dev/kvm -a -w /dev/kvm; grep -Eq '(vmx|svm)' /proc/cpuinfo; virsh_cmd capabilities >"$OUT" ;;
  02:run)
    need qemu-img; mkdir -p "$STATE_DIR/lab02"
    qemu-img create -f qcow2 "$STATE_DIR/lab02/dynamic.qcow2" 1G
    qemu-img create -f raw "$STATE_DIR/lab02/fixed.raw" 64M
    qemu-img info --output=json "$STATE_DIR/lab02/dynamic.qcow2" >"$OUT"
    ;;
  02:verify)
    qemu-img check "$STATE_DIR/lab02/dynamic.qcow2" | tee "$OUT"
    [[ "$(stat -c %s "$STATE_DIR/lab02/fixed.raw")" -eq 67108864 ]]
    ;;
  03:run)
    need qemu-system-x86_64
    MEDIA="${QEMU_LABS_BOOT_MEDIA:?Define QEMU_LABS_BOOT_MEDIA con una ISO o imagen arrancable real.}"
    [[ -f "$MEDIA" ]] || die "No existe $MEDIA"
    timeout 20 qemu-system-x86_64 -machine accel=tcg -m 512 -boot d -cdrom "$MEDIA" -display none -serial stdio -no-reboot | tee "$OUT" || status=$?
    [[ "${status:-124}" -eq 124 ]] || [[ "${status:-0}" -eq 0 ]]
    ;;
  03:verify) grep -Eiq 'boot|linux|grub|ubuntu|debian|qemu' "$OUT" || die "No se observó evidencia de arranque en $OUT" ;;
  04:run) "$ROOT_DIR/scripts/download-cloud-image.sh"; "$ROOT_DIR/scripts/create-cloud-init.sh" "$NAME"; "$ROOT_DIR/scripts/start.sh" "$NAME" ;;
  04:verify)
    "$ROOT_DIR/scripts/verify.sh" "$NAME"
    IP="$(virsh_cmd domifaddr "$NAME" --source agent | awk '/ipv4/ {sub(/\/.*/, "", $4); print $4; exit}')"
    [[ -n "$IP" ]] || die "Guest agent aún no publicó una IPv4."
    ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "lab@$IP" 'test "$(cat /var/tmp/qemu-kvm-labs-ready)" = "qemu-kvm-labs ready"' | tee "$OUT"
    ;;
  05:run)
    virsh_cmd net-info default | tee "$OUT"
    if [[ "${QEMU_LABS_ENABLE_TAP:-0}" == 1 ]]; then "$ROOT_DIR/configs/networks/tap-up.sh"; fi
    ;;
  05:verify) virsh_cmd net-dumpxml default | tee "$OUT"; grep -q "forward mode='nat'" "$OUT" ;;
  06:run)
    vm-manager --state-dir "$STATE_DIR" --uri "$LIBVIRT_URI" snapshot "$NAME" "lab06-baseline"
    vm-manager --state-dir "$STATE_DIR" --uri "$LIBVIRT_URI" clone "$NAME" "$NAME-clone" | tee "$OUT"
    ;;
  06:verify) virsh_cmd snapshot-list "$NAME" | grep -q lab06-baseline; virsh_cmd dominfo "$NAME-clone" | tee "$OUT" ;;
  07:run) virsh_cmd dumpxml "$NAME" >"$OUT" ;;
  07:verify) grep -q "bus='virtio'" "$OUT"; grep -q "model type='virtio'" "$OUT" ;;
  08:run)
    require_kvm
    virsh_cmd vcpupin "$NAME" 0 0
    virsh_cmd setmem "$NAME" 1G --live
    virsh_cmd domstats "$NAME" --cpu-total --balloon --block | tee "$OUT"
    ;;
  08:verify) virsh_cmd vcpupin "$NAME" | tee "$OUT"; virsh_cmd dommemstat "$NAME" >>"$OUT" ;;
  09:run) virsh_cmd qemu-agent-command "$NAME" '{"execute":"guest-ping"}' | tee "$OUT" ;;
  09:verify) grep -q '"return"' "$OUT"; virsh_cmd domifaddr "$NAME" --source agent >>"$OUT" ;;
  10:run)
    virsh_cmd dumpxml "$NAME" >"$OUT"
    virsh_cmd domdisplay "$NAME" >>"$OUT"
    ;;
  10:verify) grep -Eq "graphics type='(spice|vnc)'" "$OUT"; grep -q "<domain type='kvm'" "$OUT" ;;
  11:run)
    [[ "$NAME" == lab-* ]] || die "El lab de fallos solo acepta una VM cuyo nombre empiece por lab-."
    virsh_cmd domif-setlink "$NAME" vnet0 down
    sleep 2
    virsh_cmd domif-setlink "$NAME" vnet0 up
    virsh_cmd setmem "$NAME" 512M --live
    virsh_cmd domstats "$NAME" --balloon --block | tee "$OUT"
    ;;
  11:verify) [[ "$(virsh_cmd domstate "$NAME")" == running ]]; virsh_cmd domiflist "$NAME" | tee "$OUT" ;;
  12:run)
    DEST="${QEMU_LABS_MIGRATION_URI:?Define QEMU_LABS_MIGRATION_URI con el segundo host, por ejemplo qemu+ssh://host/system.}"
    virsh_cmd migrate --live --persistent --undefinesource "$NAME" "$DEST" | tee "$OUT"
    ;;
  12:verify)
    DEST="${QEMU_LABS_MIGRATION_URI:?Define QEMU_LABS_MIGRATION_URI.}"
    virsh --connect "$DEST" dominfo "$NAME" | tee "$OUT"
    ;;
  *) die "Lab/acción desconocida: $ACTION $MODE" ;;
esac
log "Lab $ACTION $MODE completado; evidencia: $OUT"
