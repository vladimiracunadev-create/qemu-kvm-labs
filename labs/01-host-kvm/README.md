# 01 · Host y aceleración KVM

## Objetivos de aprendizaje
Reconocer virtualización de CPU, permisos de /dev/kvm y la conexión libvirt.

## Teoría esencial y arquitectura
KVM convierte Linux en hipervisor; QEMU aporta la máquina y libvirt su API. Flujo: virsh → libvirt → QEMU → KVM → CPU.

## Instalación y requisitos
Linux físico o WSL2 con virtualización anidada, scripts/install.sh y grupos kvm,libvirt.

## Laboratorio guiado
Ejecuta ./run.sh e inspecciona evidence/runtime/host.json.

## Ejercicio autónomo y desafío
Compara virsh capabilities con lscpu. Explica por qué vmx/svm visible no garantiza acceso a /dev/kvm.

## Verificación automática
./verify.sh exige CPU, dispositivo KVM y capacidades libvirt reales.

## Troubleshooting
Activa VT-x/AMD-V y vuelve a iniciar sesión tras cambiar grupos.

## Preguntas de evaluación
¿Qué responsabilidades separan KVM, QEMU y libvirt? ¿Qué permiso controla /dev/kvm?

## Fuentes oficiales
[KVM](https://linux-kvm.org/) · [Libvirt](https://libvirt.org/architecture.html)

## Conclusiones y evidencia esperada
El host queda aceptado o se detiene con causa concreta; genera JSON y versiones en evidence/runtime.
