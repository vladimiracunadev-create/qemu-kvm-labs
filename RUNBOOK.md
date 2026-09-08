# Runbook

## Diagnóstico

Ejecuta scripts/check-host.sh. Revisa evidence/runtime/host.json, la versión de virsh y permisos de /dev/kvm.

## Recuperación

Para una VM que no responde, prueba virsh console NOMBRE y luego virsh shutdown NOMBRE. destroy corta energía virtual y solo debe usarse cuando el apagado limpio falla.

## Estado y almacenamiento

vm-manager list consulta libvirt. state/registry.json identifica recursos administrados. Ejecuta qemu-img check sin escritores activos.

## Limpieza

scripts/cleanup.sh NOMBRE elimina dominio y overlay administrado. scripts/cleanup.sh --all recorre únicamente el registro local.
