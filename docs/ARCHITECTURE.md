# Arquitectura

La CLI ejecuta virsh contra una URI libvirt explícita y usa qemu-img para discos. Esto mantiene trazabilidad, control de acceso y compatibilidad con las herramientas del host.

El registro state/registry.json contiene solo recursos creados por vm-manager. Las escrituras son atómicas. Antes de borrar un disco, la CLI verifica que su ruta siga dentro de state/disks.

La VM usa máquina q35, CPU host-passthrough, disco y red Virtio, NAT default, canal de guest agent, consola serie y SPICE en loopback. Cloud-init agrega una clave pública y el agente; nunca incorpora una clave privada.

## Límites

Host-passthrough maximiza fidelidad local pero restringe migración entre CPUs distintas. El prototipo no administra pools externos ni credenciales. Para producción se deben añadir autorización, locking concurrente, backup y auditoría.
