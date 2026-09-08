# 04 · Cloud-init y SSH real

## Objetivos de aprendizaje

Provisionar Ubuntu, instalar guest agent y entrar por SSH con clave.

## Teoría esencial y arquitectura

Una seed NoCloud entrega identidad al guest; DHCP asigna IP y el agente la publica al host.

## Instalación y requisitos

KVM, libvirt, cloud-localds, red default y una clave Ed25519 local.

## Laboratorio guiado

./run.sh descarga y verifica Ubuntu 24.04, genera la seed, define y arranca lab-vm.

## Ejercicio autónomo y desafío

Añade un paquete a user-data y crea otra VM. Verifica un servicio propio por SSH.

## Verificación automática

./verify.sh consulta IP mediante el agente y comprueba dentro del guest el marcador de cloud-init.

## Troubleshooting

Usa virsh console y cloud-init status --long dentro del guest.

## Preguntas de evaluación

¿Por qué una seed no debe contener claves privadas? ¿Qué aporta el agente?

## Fuentes oficiales

[cloud-init NoCloud](https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html)

## Conclusiones y evidencia esperada

VM accesible y evidencias de estado, dirección y métricas.
