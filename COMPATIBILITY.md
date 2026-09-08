# Compatibilidad

| Capacidad | Linux con KVM | WSL2 con KVM visible | macOS | GitHub-hosted CI |
| --- | ---: | ---: | ---: | ---: |
| qemu-img | Sí | Sí | Sí | Validación opcional |
| QEMU TCG | Sí | Sí | Sí | No ejecutado |
| KVM | Sí | Condicionado | No | No asumido |
| libvirt system | Sí | Condicionado | Parcial | No |
| NAT | Sí | Condicionado | Parcial | Contrato XML |
| Bridge/TAP | Sí, root | Condicionado | No | No |
| Live migration | Dos hosts | Dos entornos compatibles | No validado | No |

La detección del host prevalece sobre esta tabla. Una combinación marcada Sí puede fallar por firmware, permisos, kernel o políticas del equipo.
