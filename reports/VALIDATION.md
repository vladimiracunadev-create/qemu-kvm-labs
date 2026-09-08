# Informe de validación · v1.0.0

Fecha: 2026-09-08

## Plataforma ejecutada

- Host de construcción: Windows, sandbox de Codex.
- Python: 3.12.9.
- KVM/libvirt: no accesibles desde el sandbox de construcción.

## Resultados

| Comprobación | Resultado |
|---|---|
| Compilación Python | OK |
| Tests unitarios | OK, 14 de 14 |
| Catálogo, estructura y XML | OK, 12 labs y XML parseable |
| Sintaxis Bash | OK, Git Bash validó todos los scripts con bash -n |
| Secretos y artefactos grandes | OK, revisión local sin imágenes VM versionadas |
| VM KVM, SSH, redes y guest agent | Condicionado: requiere Linux con /dev/kvm |
| Live migration | Condicionado: requiere dos hosts compatibles |

## Limitaciones honestas

El entorno de construcción no expone /dev/kvm ni un daemon libvirt. Por ello no se afirma que una VM haya arrancado aquí. Los scripts detectan estas condiciones, generan evidencia cuando se ejecutan en un host compatible y devuelven error al invocar directamente un laboratorio incompatible.
