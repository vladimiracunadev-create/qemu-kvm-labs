# 02 · Discos qcow2 y raw

## Objetivos de aprendizaje

Crear, inspeccionar y comprobar imágenes reales qcow2 y raw.

## Teoría esencial y arquitectura

Raw refleja un dispositivo lineal; qcow2 añade asignación dinámica, metadatos, snapshots y backing files.

## Instalación y requisitos

Requiere qemu-img; no requiere KVM.

## Laboratorio guiado

Ejecuta ./run.sh para crear ambos formatos bajo state/lab02 y compara ls -lh con du -h.

## Ejercicio autónomo y desafío

Convierte raw a qcow2. Después crea una capa con backing file y demuestra que la base no cambia.

## Verificación automática

./verify.sh ejecuta qemu-img check y valida el tamaño raw.

## Troubleshooting

No abras dos escritores sobre una imagen; revisa espacio libre y permisos.

## Preguntas de evaluación

¿Cuándo prima raw? ¿Qué riesgo añade una cadena de backing files?

## Fuentes oficiales

[QEMU disk images](https://www.qemu.org/docs/master/system/images.html)

## Conclusiones y evidencia esperada

Dos imágenes reales y metadatos verificables en evidence/runtime/lab-02.
