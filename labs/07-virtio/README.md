# 07 · Dispositivos Virtio

## Objetivos de aprendizaje

Comprobar buses paravirtualizados de red, disco y canal del agente.

## Teoría esencial y arquitectura

Virtio evita emular hardware legado y define colas eficientes entre frontend guest y backend host.

## Instalación y requisitos

Una VM definida por vm-manager.

## Laboratorio guiado

./run.sh vuelca el XML efectivo del dominio.

## Ejercicio autónomo y desafío

Compara lspci y lsblk dentro del guest. Mide IOPS con caché none y documenta límites del host.

## Verificación automática

./verify.sh exige disco y NIC Virtio en el XML.

## Troubleshooting

Guests antiguos pueden necesitar drivers Virtio antes de cambiar el bus de disco.

## Preguntas de evaluación

¿Por qué Virtio mejora rendimiento? ¿Qué hace una virtqueue?

## Fuentes oficiales

[Virtio 1.3](https://docs.oasis-open.org/virtio/virtio/v1.3/virtio-v1.3.html)

## Conclusiones y evidencia esperada

XML real con controladores paravirtualizados.
