# Conceptos y preguntas frecuentes

## Una VM en una frase

Una máquina virtual es un ordenador definido por software. Tiene CPU, memoria, firmware, discos y red propios, pero utiliza recursos físicos del host. Ejecuta un sistema operativo invitado que se comporta como si tuviera una máquina para sí mismo.

## QEMU

QEMU crea el modelo de máquina. Emula dispositivos y puede traducir instrucciones de una arquitectura a otra mediante TCG. Esa traducción permite experimentar incluso sin aceleración, aunque su rendimiento es menor.

## KVM

KVM es una función del kernel Linux que expone aceleración de virtualización a procesos como QEMU. El archivo /dev/kvm es la puerta de acceso. La CPU debe ofrecer VT-x en Intel o AMD-V en AMD, el firmware debe habilitarla y el usuario debe tener permisos.

## Libvirt y virsh

Libvirt administra máquinas virtuales como dominios persistentes. Guarda su definición, coordina redes y almacenamiento y ofrece operaciones uniformes. Virsh es un cliente de esa API. El proyecto usa qemu:///system porque representa el daemon del host y sus recursos compartidos.

## Qué ocurre al crear una VM

1. Se valida el nombre, la imagen base y los recursos solicitados.
2. qemu-img crea un overlay qcow2. Las escrituras del guest van al overlay y la base permanece intacta.
3. vm-manager genera XML con CPU, RAM, disco Virtio, NIC, agente y consola.
4. virsh define ese XML en libvirt.
5. Al arrancar, libvirt crea un proceso QEMU y abre /dev/kvm.
6. QEMU presenta el hardware virtual al firmware y al sistema invitado.
7. Cloud-init lee la seed, crea el usuario, autoriza la clave pública e instala el agente.
8. La red NAT asigna una IP; SSH y el agente permiten verificar el guest desde el host.

## Qué persiste

Libvirt conserva la definición del dominio. El directorio state conserva el registro de vm-manager, XML generado, seeds y overlays. La imagen Ubuntu en images funciona como base reutilizable. La evidencia se escribe en evidence/runtime y no se versiona.

## Qué significa aislamiento

El guest tiene su propio kernel y espacio de usuario. KVM y QEMU median el acceso a CPU, memoria y dispositivos. El aislamiento depende también del kernel, libvirt, permisos, configuración de red y actualizaciones del host.

## Diferencia frente a contenedores

Un contenedor comparte el kernel del host. Una VM arranca un kernel invitado y recibe hardware virtual. Las VMs permiten probar otro kernel y ofrecen una frontera distinta de aislamiento a cambio de consumir más recursos y tardar más en arrancar.

## Diferencia frente a Docker Desktop o una nube

Docker Desktop puede usar una VM internamente para ofrecer contenedores. Una nube combina hipervisores con redes, identidad, almacenamiento, APIs y planificación a gran escala. Este repositorio estudia el estrato de virtualización local sobre el que pueden construirse esas plataformas.

## Cuándo usar cada red

- NAT para dar salida al guest con una configuración local sencilla.
- Bridge para que el guest aparezca en la misma red de capa 2 que el host.
- TAP para conectar QEMU a una interfaz virtual controlada por scripts o switches.

## Por qué qcow2

qcow2 permite overlays, asignación dinámica y snapshots. Facilita crear muchas VMs desde una base sin duplicarla al principio. La dependencia entre base y overlays debe conservarse y respaldarse conscientemente.

## Qué demuestra la evidencia

Un mensaje de éxito escrito de antemano no demuestra virtualización. Por eso las verificaciones consultan fuentes vivas: capacidades de libvirt, qemu-img check, domstate, domstats, direcciones informadas por el agente, SSH al guest y presencia del dominio migrado en el segundo host.

## Qué hacer primero

Ejecuta los labs 01, 02 y 03 para separar host, almacenamiento y arranque. El lab 04 integra la primera VM completa. Desde ese punto, los demás laboratorios operan sobre esa VM y terminan en vm-manager.
