# 09 · QEMU Guest Agent

## Objetivos de aprendizaje

Ejecutar una llamada del agente mediada por libvirt y consultar la red del guest.

## Teoría esencial y arquitectura

El agente dentro del guest habla por un canal Virtio serial; libvirt expone operaciones coordinadas al host.

## Instalación y requisitos

qemu-guest-agent activo dentro de la VM y canal org.qemu.guest_agent.0.

## Laboratorio guiado

./run.sh envía guest-ping a una VM real.

## Ejercicio autónomo y desafío

Consulta guest-info. Después implementa freeze y thaw en un filesystem desechable con manejo seguro de errores.

## Verificación automática

./verify.sh exige respuesta JSON y direcciones publicadas por el agente.

## Troubleshooting

Revisa systemctl status qemu-guest-agent dentro del guest y el canal en el XML.

## Preguntas de evaluación

¿Qué confianza deposita el host en el agente? ¿Por qué restringir comandos?

## Fuentes oficiales

[QEMU Guest Agent](https://www.qemu.org/docs/master/interop/qemu-ga.html)

## Conclusiones y evidencia esperada

Respuesta real del agente y tabla de interfaces.
