# 12 · Migración y proyecto final vm-manager

## Objetivos de aprendizaje
Gestionar el ciclo completo y migrar una VM entre dos hosts compatibles.

## Teoría esencial y arquitectura
vm-manager mantiene un registro local y llama a libvirt y qemu-img reales. La migración transfiere memoria; el almacenamiento debe compartirse o copiarse.

## Instalación y requisitos
Instala el paquete con pip install -e . Para migrar define QEMU_LABS_MIGRATION_URI hacia un segundo host compatible.

## Laboratorio guiado
Usa vm-manager para crear, listar, arrancar, detener, clonar, snapshotear y eliminar. ./run.sh ejecuta migración real.

## Ejercicio autónomo y desafío
Automatiza el ciclo completo. Mide downtime y diseña una política NUMA compatible entre hosts.

## Verificación automática
./verify.sh exige que el dominio exista en el destino; sin segundo host termina con un error explícito.

## Troubleshooting
Revisa conectividad, autenticación, daemon libvirt, CPU y rutas de disco.

## Preguntas de evaluación
¿Qué debe ser compatible? ¿Qué estado pertenece al registro y cuál a libvirt?

## Fuentes oficiales
[Libvirt migration](https://libvirt.org/migration.html) · [QEMU migration](https://www.qemu.org/docs/master/interop/live-block-operations.html)

## Conclusiones y evidencia esperada
CLI funcional y, cuando hay dos hosts, dominfo real en destino.
