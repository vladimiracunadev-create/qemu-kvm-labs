# Guía de laboratorios

Avanza en orden. Los labs 01 a 03 preparan fundamentos; 04 crea la VM base; 05 a 10 la inspeccionan y modifican; 11 exige que sea desechable; 12 integra la CLI y condiciona migración a dos hosts.

Cada directorio ofrece run.sh y verify.sh. Define QEMU_LABS_VM para cambiar el dominio, QEMU_LABS_STATE para aislar el estado y QEMU_LABS_EVIDENCE para dirigir evidencias.

verify-all registra una omisión explícita cuando el host carece de KVM. Ejecutar directamente un lab incompatible devuelve código distinto de cero.
