# 05 · NAT, bridge y TAP

## Objetivos de aprendizaje
Distinguir red NAT administrada, bridge de capa 2 y dispositivo TAP.

## Teoría esencial y arquitectura
NAT conecta el guest mediante virbr0; bridge lo une al segmento físico; TAP es el puerto virtual consumido por QEMU.

## Instalación y requisitos
Libvirt; bridge y TAP requieren privilegios y una interfaz br0 preparada.

## Laboratorio guiado
./run.sh inspecciona la NAT. Solo QEMU_LABS_ENABLE_TAP=1 crea TAP con la configuración incluida.

## Ejercicio autónomo y desafío
Obtén leases con virsh net-dhcp-leases default. Diseña br0 sin perder la ruta de administración.

## Verificación automática
./verify.sh valida el XML activo y su modo NAT.

## Troubleshooting
No cambies bridges por SSH sin consola alternativa; revisa firewall y forwarding IPv4.

## Preguntas de evaluación
¿Cuándo usar NAT frente a bridge? ¿Qué capa representa TAP?

## Fuentes oficiales
[Libvirt network XML](https://libvirt.org/formatnetwork.html)

## Conclusiones y evidencia esperada
XML de la red activa bajo evidence/runtime/lab-05.
