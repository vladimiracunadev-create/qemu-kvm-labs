from __future__ import annotations

import json
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

from qemu_kvm_labs.vm_manager import VMError, VMManager, VMRecord, build_parser


class RecordingRunner:
    def __init__(self, domains=()):
        self.commands = []
        self.domains = set(domains)

    def run(self, argv, *, capture=True):
        self.commands.append(tuple(argv))
        if "list" in argv and "--name" in argv:
            return "\n".join(sorted(self.domains))
        if "dominfo" in argv:
            name = argv[-1]
            if name not in self.domains:
                raise VMError("domain missing")
            return f"Name: {name}"
        if "define" in argv:
            self.domains.add(Path(argv[-1]).stem)
        return "ok"


class VMManagerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.runner = RecordingRunner()
        self.manager = VMManager(self.root / "state", runner=self.runner)
        self.base = self.root / "base.qcow2"
        self.base.write_bytes(b"qcow2-test-placeholder")

    def tearDown(self):
        self.tmp.cleanup()

    def test_rejects_invalid_name(self):
        with self.assertRaises(VMError):
            self.manager.create("bad name", self.base, 512, 1, None)

    def test_rejects_missing_image(self):
        with self.assertRaisesRegex(VMError, "No existe"):
            self.manager.create("demo", self.root / "missing", 512, 1, None)

    def test_rejects_tiny_machine(self):
        with self.assertRaisesRegex(VMError, "256 MiB"):
            self.manager.create("demo", self.base, 128, 0, None)

    def test_create_generates_valid_virtio_domain_and_registry(self):
        record = self.manager.create("demo", self.base, 1024, 2, None)
        xml = ET.parse(self.root / "state" / "demo.xml")
        self.assertEqual(xml.findtext("name"), "demo")
        self.assertEqual(xml.find("./devices/disk/target").attrib["bus"], "virtio")
        self.assertEqual(json.loads((self.root / "state" / "registry.json").read_text())["demo"]["disk"], record.disk)

    def test_create_rejects_existing_libvirt_domain(self):
        manager = VMManager(self.root / "state", runner=RecordingRunner({"demo"}))
        with self.assertRaisesRegex(VMError, "libvirt"):
            manager.create("demo", self.base, 512, 1, None)

    def test_cloud_init_is_attached_read_only(self):
        seed = self.root / "seed.iso"
        seed.write_bytes(b"seed")
        self.manager.create("cloud", self.base, 512, 1, seed)
        xml = ET.parse(self.root / "state" / "cloud.xml")
        cdrom = xml.find("./devices/disk[@device='cdrom']")
        self.assertIsNotNone(cdrom.find("readonly"))

    def test_snapshot_uses_atomic_virsh_operation(self):
        self.manager.snapshot("demo", "before-upgrade")
        self.assertIn(("virsh", "--connect", "qemu:///system", "snapshot-create-as", "demo", "before-upgrade", "--atomic"), self.runner.commands)

    def test_stop_defaults_to_graceful_shutdown(self):
        self.manager.stop("demo")
        self.assertEqual(self.runner.commands[-1][-2:], ("shutdown", "demo"))

    def test_force_stop_uses_destroy(self):
        self.manager.stop("demo", force=True)
        self.assertEqual(self.runner.commands[-1][-2:], ("destroy", "demo"))

    def test_parser_requires_create_image(self):
        with self.assertRaises(SystemExit):
            build_parser().parse_args(["create", "demo"])

    def test_domain_xml_uses_host_passthrough_and_agent(self):
        record = VMRecord("demo", "/tmp/demo.qcow2", 512, 1, "qemu:///system")
        root = ET.fromstring(VMManager._domain_xml(record, None))
        self.assertEqual(root.find("cpu").attrib["mode"], "host-passthrough")
        self.assertEqual(root.find("./devices/channel/target").attrib["name"], "org.qemu.guest_agent.0")


if __name__ == "__main__":
    unittest.main()
