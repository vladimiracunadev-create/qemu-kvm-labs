# 08 · CPU pinning, memoria y almacenamiento

## Objetivos de aprendizaje

Aplicar afinidad de vCPU, ballooning y observar I/O.

## Teoría esencial y arquitectura

El scheduler ubica vCPU en CPU host; balloon ajusta memoria guest y los contadores de bloque muestran actividad.

## Instalación y requisitos

KVM, lab-vm en ejecución y al menos una CPU host.

## Laboratorio guiado

./run.sh fija vCPU 0, ajusta memoria viva a 1 GiB y captura estadísticas.

## Ejercicio autónomo y desafío

Compara cpu-stats con carga controlada. Diseña una política NUMA para un host de dos sockets.

## Verificación automática

./verify.sh lee afinidad y memoria efectivas.

## Troubleshooting

El guest requiere balloon driver; respeta su memoria mínima operativa.

## Preguntas de evaluación

¿Cuándo empeora el pinning? ¿Qué diferencia hay entre asignación y uso?

## Fuentes oficiales

[Libvirt CPU tuning](https://libvirt.org/formatdomain.html#cpu-tuning)

## Conclusiones y evidencia esperada

Afinidad y telemetría reales en evidence/runtime/lab-08.
