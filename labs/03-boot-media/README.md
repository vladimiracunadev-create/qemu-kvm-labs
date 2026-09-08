# 03 · Arranque desde ISO e imagen

## Objetivos de aprendizaje
Observar firmware, orden de arranque y consola serie de una VM QEMU.

## Teoría esencial y arquitectura
QEMU presenta una máquina q35; el firmware busca medios y entrega control al cargador. TCG permite ejecutar sin KVM, con menor rendimiento.

## Instalación y requisitos
QEMU y una ISO arrancable propia indicada con QEMU_LABS_BOOT_MEDIA.

## Laboratorio guiado
Ejecuta ./run.sh; arranca durante 20 segundos sin interfaz gráfica y guarda la consola.

## Ejercicio autónomo y desafío
Repite con examples/direct-qemu.sh. Cambia a UEFI con OVMF y compara el log.

## Verificación automática
./verify.sh busca evidencia real de firmware o cargador en la salida.

## Troubleshooting
Una ISO solo gráfica puede arrancar sin texto; usa una imagen con consola serie.

## Preguntas de evaluación
¿Qué cambia entre cdrom, drive y el orden de boot?

## Fuentes oficiales
[QEMU invocation](https://www.qemu.org/docs/master/system/invocation.html)

## Conclusiones y evidencia esperada
Registro de un arranque real en evidence/runtime/lab-03/run.txt.
