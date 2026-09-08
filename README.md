# QEMU KVM Labs

> Laboratorio progresivo y reproducible para dominar virtualización Linux real con QEMU, KVM y libvirt.

[![CI](https://github.com/vladimiracunadev-create/qemu-kvm-labs/actions/workflows/ci.yml/badge.svg)](https://github.com/vladimiracunadev-create/qemu-kvm-labs/actions/workflows/ci.yml)
[![Pages](https://github.com/vladimiracunadev-create/qemu-kvm-labs/actions/workflows/pages.yml/badge.svg)](https://github.com/vladimiracunadev-create/qemu-kvm-labs/actions/workflows/pages.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

## Estado · v1.0.0

Doce laboratorios conectan QEMU, KVM, libvirt, virsh, qcow2, cloud-init, redes, Virtio, UEFI, guest agent, snapshots y migración. El proyecto final, vm-manager, crea y opera dominios reales. Ningún script inventa resultados: cuando faltan Linux, KVM, permisos o un segundo host, termina con un diagnóstico y registra el límite.

Las versiones upstream verificadas al crear esta versión son QEMU 11.1.1 y libvirt 12.7.0. Los scripts instalan las versiones mantenidas por la distribución para conservar integración con su kernel y daemon.

## Qué es QEMU y por qué existe este repositorio

QEMU es un emulador y virtualizador de máquinas. Puede construir por software el hardware que espera un sistema operativo invitado: CPU, memoria, discos, tarjetas de red, firmware y consola. En un host Linux, KVM permite que la CPU invitada ejecute instrucciones directamente sobre la CPU física con aislamiento del kernel. Libvirt añade una API estable y virsh ofrece su interfaz de línea de comandos.

Estas piezas suelen aparecer juntas, pero resuelven problemas distintos:

| Pieza | Responsabilidad | Ejemplo en este repositorio |
| --- | --- | --- |
| QEMU | Crea el modelo de hardware virtual y ejecuta la VM | Máquina q35, discos, NIC y consola |
| KVM | Acelera la CPU invitada mediante el kernel Linux | Acceso a /dev/kvm |
| libvirt | Mantiene dominios, redes, snapshots y políticas | Conexión qemu:///system |
| virsh | Permite operar libvirt desde terminal | start, shutdown, snapshot-create-as |
| cloud-init | Configura el guest durante su primer arranque | Usuario, clave SSH y guest agent |
| vm-manager | Une el flujo del curso en una CLI pequeña | create, list, clone, snapshot y delete |

El repositorio existe para convertir esa arquitectura en experiencia práctica. Instalar QEMU por sí solo no enseña cómo se relacionan discos, firmware, red, provisioning, estado y ciclo de vida. Aquí cada concepto termina en un recurso real y una evidencia que puede inspeccionarse.

## Qué estás levantando

El flujo principal crea una máquina virtual Ubuntu aislada dentro del host Linux. La VM recibe CPU y memoria virtuales, un overlay qcow2 basado en una imagen oficial, una NIC Virtio conectada a la red NAT de libvirt, configuración cloud-init, acceso SSH y un canal para QEMU Guest Agent.

~~~text
Host Linux o WSL2 compatible
└── libvirt: inventario y ciclo de vida
    └── proceso QEMU acelerado por KVM
        ├── CPU y RAM virtuales
        ├── disco qcow2 sobre imagen Ubuntu verificada
        ├── NIC Virtio en NAT, bridge o TAP
        ├── firmware BIOS o UEFI
        └── guest Ubuntu accesible por SSH y guest agent
~~~

Gestionas infraestructura de virtualización local: definición, arranque, parada, clonación, snapshots, recursos, conectividad, consola y eliminación de VMs. Los labs también muestran cómo diagnosticar fallos y, con dos hosts compatibles, mover una VM en ejecución.

## Para qué sirve en la práctica

- Aprender la base que usan nubes privadas, homelabs y plataformas de virtualización.
- Probar kernels, imágenes, redes y servicios en entornos aislados y reproducibles.
- Entender qué ocurre debajo de herramientas como virt-manager y OpenStack.
- Practicar automatización de VMs sin depender de una cuenta cloud.
- Construir criterio operativo sobre rendimiento, almacenamiento, recuperación y migración.

Empieza por [Conceptos y preguntas frecuentes](docs/CONCEPTS.md) si QEMU, KVM y libvirt son nuevos para ti.

## Arquitectura

~~~mermaid
flowchart LR
    U[Usuario] --> CLI[vm-manager]
    U --> LABS[12 labs]
    CLI --> V[virsh]
    LABS --> V
    V --> L[libvirt]
    L --> Q[QEMU]
    Q --> K[KVM]
    K --> CPU[CPU host]
    Q --> D[(qcow2 / raw)]
    Q --> N[NAT / bridge / TAP]
    A[cloud-init] --> G[Guest Linux]
    G --> GA[QEMU Guest Agent]
    GA --> L
~~~

## Requisitos y compatibilidad

| Host | QEMU TCG | KVM | libvirt | Ruta recomendada |
| --- | ---: | ---: | ---: | --- |
| Linux x86_64 | Sí | Sí, con VT-x/AMD-V | Sí | Soporte completo |
| Windows 11 + WSL2 | Sí | Condicionado a KVM anidado | Sí dentro de WSL2 | Labs compatibles |
| Windows nativo | Sí | No | Limitado | Usar WSL2 |
| macOS | Sí | No | Limitado | Labs 02 y 03 con TCG |
| GitHub-hosted runner | Contratos | No garantizado | No requerido | CI estático y unitario |

Necesitas Python 3.11 o superior. Los laboratorios completos requieren Linux, CPU con virtualización habilitada, acceso a /dev/kvm, QEMU, libvirt, virsh, cloud-image-utils y OVMF. El almacenamiento puede crecer varios GiB. No hay costo cloud salvo que configures infraestructura externa.

## Instalación

~~~bash
git clone https://github.com/vladimiracunadev-create/qemu-kvm-labs.git
cd qemu-kvm-labs
./scripts/install.sh
# abre una sesión nueva para aplicar los grupos kvm y libvirt
./scripts/check-host.sh
./scripts/setup.sh
~~~

## Ruta de aprendizaje

| # | Laboratorio | Resultado real | Compatibilidad |
| ---: | --- | --- | --- |
| 01 | [Host y KVM](labs/01-host-kvm/) | Capacidades CPU, KVM y libvirt | Linux/WSL2 compatible |
| 02 | [Discos](labs/02-disk-images/) | Imágenes qcow2 y raw comprobadas | Linux, macOS, WSL2 |
| 03 | [Boot media](labs/03-boot-media/) | Arranque QEMU desde ISO | TCG o KVM |
| 04 | [Cloud-init y SSH](labs/04-cloud-init-ssh/) | Guest Ubuntu provisionado | KVM/libvirt |
| 05 | [Redes](labs/05-networking/) | NAT, bridge y TAP | Linux |
| 06 | [Snapshots y clones](labs/06-snapshots-clones/) | Snapshot y clon reales | KVM/libvirt |
| 07 | [Virtio](labs/07-virtio/) | NIC, disco y agente paravirtualizados | KVM/libvirt |
| 08 | [Recursos](labs/08-resources/) | CPU pinning y ballooning | KVM/libvirt |
| 09 | [Guest agent](labs/09-guest-agent/) | Comando y red del guest | Agente instalado |
| 10 | [XML, UEFI y consola](labs/10-xml-uefi-console/) | XML y URI SPICE | OVMF/libvirt |
| 11 | [Fallos controlados](labs/11-failure-injection/) | Corte de NIC y presión de memoria | VM desechable |
| 12 | [Migración y vm-manager](labs/12-migration-vm-manager/) | Gestión completa y migración | Dos hosts para migrar |

Cada unidad contiene objetivos, teoría, requisitos, práctica guiada, ejercicio, desafío, verificación, troubleshooting, evaluación, fuentes y evidencia.

## Flujo reproducible

~~~bash
./scripts/check-host.sh
./scripts/install.sh
./scripts/setup.sh
./scripts/download-cloud-image.sh
./scripts/start.sh lab-vm
./scripts/verify.sh lab-vm
./scripts/test.sh
./scripts/stop.sh lab-vm
./scripts/cleanup.sh lab-vm
~~~

El instalador requiere sudo. La descarga obtiene Ubuntu 24.04 LTS desde el servidor oficial y compara SHA-256.

## Proyecto final: vm-manager

~~~bash
vm-manager create demo --base-image images/ubuntu-24.04-amd64.qcow2 --cloud-init state/demo-seed.iso
vm-manager start demo
vm-manager list
vm-manager snapshot demo before-upgrade
vm-manager clone demo demo-copy
vm-manager stop demo
vm-manager delete demo --force
~~~

La URI predeterminada es qemu:///system. Para otro daemon usa --uri o QEMU_LABS_URI. El estado se guarda de forma atómica y solo se eliminan discos dentro del directorio administrado.

## Verificación y evidencia

~~~bash
./scripts/verify-all.sh
python3 scripts/validate-repo.py
PYTHONPATH=src python3 -m unittest discover -s tests -v
~~~

La evidencia runtime aparece en evidence/runtime y está ignorada por Git. [reports/VALIDATION.md](reports/VALIDATION.md) separa lo ejecutado de lo condicionado por hardware.

## Limpieza

~~~bash
./scripts/cleanup.sh lab-vm
./scripts/cleanup.sh --all
~~~

Cleanup elimina dominios y discos registrados por vm-manager. Conserva las imágenes base.

## Documentación

- [Arquitectura](docs/ARCHITECTURE.md)
- [Conceptos y preguntas frecuentes](docs/CONCEPTS.md)
- [Guía de laboratorios](docs/LAB_GUIDE.md)
- [Compatibilidad](COMPATIBILITY.md)
- [Operación diaria](RUNBOOK.md)
- [Seguridad](SECURITY.md)
- [Contribuir](CONTRIBUTING.md)
- [Roadmap](ROADMAP.md)

## Licencia

Apache-2.0 · © 2026 Vladimir Acuña
