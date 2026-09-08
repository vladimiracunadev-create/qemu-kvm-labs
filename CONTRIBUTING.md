# Contribuir

Abre una rama desde main, limita cada cambio a un problema y conserva la ejecución real de la tecnología.

Antes de proponer cambios:

~~~bash
PYTHONPATH=src python3 -m unittest discover -s tests -v
python3 scripts/validate-repo.py
bash -n scripts/*.sh scripts/lib/*.sh labs/*/*.sh
~~~

Los nuevos labs necesitan README con toda la estructura pedagógica, run.sh, verify.sh, evidencia reproducible, cleanup y una entrada en labs.config.json. No se aceptan resultados hardcodeados, secretos ni ataques contra infraestructura ajena.
