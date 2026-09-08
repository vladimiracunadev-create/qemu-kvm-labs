# 11 · Fallos controlados

## Objetivos de aprendizaje

Aplicar una interrupción de red y presión de memoria a una VM desechable.

## Teoría esencial y arquitectura

La inyección controlada mide detección y recuperación. El script solo acepta VMs cuyo nombre comience por lab-.

## Instalación y requisitos

Una VM desechable administrada y en ejecución.

## Laboratorio guiado

./run.sh desconecta la NIC, la reconecta, reduce memoria viva y recoge estadísticas.

## Ejercicio autónomo y desafío

Mide la pérdida de paquetes. Simula disco lleno dentro de un filesystem desechable del guest.

## Verificación automática

./verify.sh exige que la VM siga ejecutándose y consulta su interfaz.

## Troubleshooting

Usa virsh console si SSH no vuelve; restaura memoria con setmem.

## Preguntas de evaluación

¿Qué señal demuestra recuperación? ¿Cómo limitas el radio de impacto?

## Fuentes oficiales

[Virsh](https://libvirt.org/manpages/virsh.html)

## Conclusiones y evidencia esperada

Telemetría del fallo y dominio recuperado.
