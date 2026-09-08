# 06 · Snapshots, restore y clones

## Objetivos de aprendizaje
Capturar estado y crear clones completos de una VM administrada.

## Teoría esencial y arquitectura
Un snapshot conserva un punto recuperable; un clon crea identidad y disco independientes. Los backing files reducen espacio pero crean dependencia.

## Instalación y requisitos
lab-vm creada por el lab 04 y apagada cuando la consistencia de aplicación importe.

## Laboratorio guiado
./run.sh crea lab06-baseline y lab-vm-clone.

## Ejercicio autónomo y desafío
Restaura el snapshot. Compara clon completo y overlay midiendo espacio y recuperación.

## Verificación automática
./verify.sh consulta el snapshot y el dominio clonado en libvirt.

## Troubleshooting
Un snapshot crash-consistent no sustituye backup; congela el filesystem mediante agente si procede.

## Preguntas de evaluación
¿Qué estado incluye un snapshot externo? ¿Qué rompe una cadena de backing?

## Fuentes oficiales
[Libvirt snapshots](https://libvirt.org/formatsnapshot.html)

## Conclusiones y evidencia esperada
Snapshot y clon reales visibles en libvirt.
