#!/usr/bin/env python3
from __future__ import annotations
import json, sys
import xml.etree.ElementTree as ET
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
required = ["README.md", "LICENSE", "CONTRIBUTING.md", "SECURITY.md", "docs", "labs", "examples", "scripts", "tests", "fixtures", "configs", "assets", "reports", ".github/workflows"]
for item in required:
    if not (ROOT / item).exists(): errors.append(f"falta {item}")
catalog = json.loads((ROOT / "labs.config.json").read_text(encoding="utf-8"))
for lab in catalog["labs"]:
    path = ROOT / lab["path"]
    for file in ("README.md", "run.sh", "verify.sh"):
        if not (path / file).is_file(): errors.append(f"falta {lab['path']}/{file}")
for xml in (ROOT / "configs").rglob("*.xml"):
    try: ET.parse(xml)
    except ET.ParseError as exc: errors.append(f"XML inválido {xml.relative_to(ROOT)}: {exc}")
version = (ROOT / "version.txt").read_text().strip()
if f'version = "{version}"' not in (ROOT / "pyproject.toml").read_text(): errors.append("pyproject.toml no coincide con version.txt")
if f'__version__ = "{version}"' not in (ROOT / "src/qemu_kvm_labs/__init__.py").read_text(): errors.append("__version__ no coincide con version.txt")
if errors:
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print(f"OK: {len(catalog['labs'])} labs, XML válido y versión {version} coherente")
