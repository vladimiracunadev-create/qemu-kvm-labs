from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class RepositoryContractTests(unittest.TestCase):
    def test_catalog_paths_exist(self):
        catalog = json.loads((ROOT / "labs.config.json").read_text(encoding="utf-8"))
        self.assertGreaterEqual(len(catalog["labs"]), 12)
        for lab in catalog["labs"]:
            self.assertTrue((ROOT / lab["path"]).is_dir(), lab["path"])

    def test_no_generated_evidence_is_committed(self):
        files = [path for path in (ROOT / "evidence").rglob("*") if path.is_file()]
        self.assertEqual(files, [ROOT / "evidence" / ".gitkeep"])

    def test_versions_agree(self):
        version = (ROOT / "version.txt").read_text().strip()
        self.assertIn(f'version = "{version}"', (ROOT / "pyproject.toml").read_text())
        self.assertIn(f'__version__ = "{version}"', (ROOT / "src/qemu_kvm_labs/__init__.py").read_text())


if __name__ == "__main__":
    unittest.main()
