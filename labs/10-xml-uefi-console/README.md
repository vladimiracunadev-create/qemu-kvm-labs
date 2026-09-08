# 10 · XML, UEFI y consolas SPICE/VNC

## Objetivos de aprendizaje

Leer el contrato XML, localizar firmware UEFI y obtener una URI gráfica.

## Teoría esencial y arquitectura

Libvirt traduce XML estable a argumentos QEMU; OVMF implementa UEFI y SPICE o VNC transportan la consola.

## Instalación y requisitos

Libvirt, OVMF y un visor compatible. La consola escucha solo en loopback.

## Laboratorio guiado

./run.sh captura XML y domdisplay.

## Ejercicio autónomo y desafío

Compara domxml-to-native con XML. Crea una VM UEFI con NVRAM desechable y Secure Boot si el host lo soporta.

## Verificación automática

./verify.sh valida dominio KVM y consola SPICE o VNC.

## Troubleshooting

Busca OVMF bajo /usr/share. No expongas VNC sin autenticación.

## Preguntas de evaluación

¿Qué persiste en NVRAM? ¿Por qué preferir XML sobre argumentos manuales?

## Fuentes oficiales

[Libvirt domain XML](https://libvirt.org/formatdomain.html)

## Conclusiones y evidencia esperada

XML real y URI gráfica bajo evidence/runtime/lab-10.
