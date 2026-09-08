"""Small, dependency-free CLI for real libvirt/QEMU virtual machines."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Sequence

NAME_RE = re.compile(r"^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,62}$")
DEFAULT_URI = "qemu:///system"


class VMError(RuntimeError):
    """An actionable vm-manager failure."""


@dataclass(frozen=True)
class VMRecord:
    name: str
    disk: str
    memory_mib: int
    vcpus: int
    connection: str


class Runner:
    def run(self, argv: Sequence[str], *, capture: bool = True) -> str:
        try:
            result = subprocess.run(
                list(argv), check=True, text=True,
                stdout=subprocess.PIPE if capture else None,
                stderr=subprocess.PIPE if capture else None,
            )
        except FileNotFoundError as exc:
            raise VMError(f"No se encontró el ejecutable requerido: {argv[0]}") from exc
        except subprocess.CalledProcessError as exc:
            detail = (exc.stderr or exc.stdout or str(exc)).strip()
            raise VMError(f"Falló {' '.join(argv)}: {detail}") from exc
        return (result.stdout or "").strip()


class VMManager:
    def __init__(self, state_dir: Path, uri: str = DEFAULT_URI, runner: Runner | None = None):
        self.state_dir = state_dir.resolve()
        self.uri = uri
        self.runner = runner or Runner()
        self.registry_path = self.state_dir / "registry.json"
        self.disks_dir = self.state_dir / "disks"

    def _virsh(self, *args: str) -> str:
        return self.runner.run(("virsh", "--connect", self.uri, *args))

    def _domain_exists(self, name: str) -> bool:
        domains = self._virsh("list", "--all", "--name").splitlines()
        return name in {domain.strip() for domain in domains if domain.strip()}

    def _load(self) -> dict[str, dict]:
        if not self.registry_path.exists():
            return {}
        try:
            value = json.loads(self.registry_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise VMError(f"Registro inválido: {self.registry_path}: {exc}") from exc
        if not isinstance(value, dict):
            raise VMError(f"El registro debe contener un objeto JSON: {self.registry_path}")
        return value

    def _save(self, registry: dict[str, dict]) -> None:
        self.state_dir.mkdir(parents=True, exist_ok=True)
        fd, temporary = tempfile.mkstemp(prefix="registry-", suffix=".json", dir=self.state_dir)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as handle:
                json.dump(registry, handle, indent=2, sort_keys=True)
                handle.write("\n")
            os.replace(temporary, self.registry_path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)

    @staticmethod
    def _validate_name(name: str) -> None:
        if not NAME_RE.fullmatch(name):
            raise VMError("Nombre inválido: usa 1-63 letras, números, puntos, guiones o guion bajo")

    @staticmethod
    def _domain_xml(record: VMRecord, cloud_init: Path | None) -> str:
        domain = ET.Element("domain", {"type": "kvm"})
        ET.SubElement(domain, "name").text = record.name
        ET.SubElement(domain, "memory", {"unit": "MiB"}).text = str(record.memory_mib)
        ET.SubElement(domain, "vcpu", {"placement": "static"}).text = str(record.vcpus)
        os_node = ET.SubElement(domain, "os")
        ET.SubElement(os_node, "type", {"arch": "x86_64", "machine": "q35"}).text = "hvm"
        features = ET.SubElement(domain, "features")
        ET.SubElement(features, "acpi")
        ET.SubElement(features, "apic")
        ET.SubElement(domain, "cpu", {"mode": "host-passthrough", "check": "none"})
        devices = ET.SubElement(domain, "devices")
        disk = ET.SubElement(devices, "disk", {"type": "file", "device": "disk"})
        ET.SubElement(disk, "driver", {"name": "qemu", "type": "qcow2", "cache": "none"})
        ET.SubElement(disk, "source", {"file": record.disk})
        ET.SubElement(disk, "target", {"dev": "vda", "bus": "virtio"})
        if cloud_init:
            seed = ET.SubElement(devices, "disk", {"type": "file", "device": "cdrom"})
            ET.SubElement(seed, "driver", {"name": "qemu", "type": "raw"})
            ET.SubElement(seed, "source", {"file": str(cloud_init.resolve())})
            ET.SubElement(seed, "target", {"dev": "sda", "bus": "sata"})
            ET.SubElement(seed, "readonly")
        interface = ET.SubElement(devices, "interface", {"type": "network"})
        ET.SubElement(interface, "source", {"network": "default"})
        ET.SubElement(interface, "model", {"type": "virtio"})
        channel = ET.SubElement(devices, "channel", {"type": "unix"})
        ET.SubElement(channel, "target", {"type": "virtio", "name": "org.qemu.guest_agent.0"})
        ET.SubElement(devices, "graphics", {"type": "spice", "autoport": "yes", "listen": "127.0.0.1"})
        ET.SubElement(devices, "console", {"type": "pty"})
        return ET.tostring(domain, encoding="unicode")

    def create(self, name: str, base_image: Path, memory_mib: int, vcpus: int, cloud_init: Path | None) -> VMRecord:
        self._validate_name(name)
        if memory_mib < 256 or vcpus < 1:
            raise VMError("La VM requiere al menos 256 MiB y 1 vCPU")
        base_image = base_image.resolve()
        if not base_image.is_file():
            raise VMError(f"No existe la imagen base: {base_image}")
        if cloud_init and not cloud_init.resolve().is_file():
            raise VMError(f"No existe la imagen cloud-init: {cloud_init}")
        registry = self._load()
        if name in registry:
            raise VMError(f"La VM ya está registrada: {name}")
        if self._domain_exists(name):
            raise VMError(f"El dominio ya existe en libvirt: {name}")
        self.disks_dir.mkdir(parents=True, exist_ok=True)
        disk = (self.disks_dir / f"{name}.qcow2").resolve()
        self.runner.run(("qemu-img", "create", "-f", "qcow2", "-F", "qcow2", "-b", str(base_image), str(disk)))
        record = VMRecord(name, str(disk), memory_mib, vcpus, self.uri)
        xml_path = self.state_dir / f"{name}.xml"
        xml_path.write_text(self._domain_xml(record, cloud_init), encoding="utf-8")
        try:
            self._virsh("define", str(xml_path))
        except Exception:
            disk.unlink(missing_ok=True)
            xml_path.unlink(missing_ok=True)
            raise
        registry[name] = asdict(record)
        self._save(registry)
        return record

    def list(self) -> str:
        return self._virsh("list", "--all", "--name")

    def start(self, name: str) -> str:
        self._validate_name(name)
        return self._virsh("start", name)

    def stop(self, name: str, force: bool = False) -> str:
        self._validate_name(name)
        return self._virsh("destroy" if force else "shutdown", name)

    def snapshot(self, name: str, snapshot_name: str) -> str:
        self._validate_name(name)
        self._validate_name(snapshot_name)
        return self._virsh("snapshot-create-as", name, snapshot_name, "--atomic")

    def clone(self, source: str, target: str) -> VMRecord:
        self._validate_name(source)
        self._validate_name(target)
        registry = self._load()
        if source not in registry:
            raise VMError(f"VM origen no registrada: {source}")
        if target in registry:
            raise VMError(f"VM destino ya registrada: {target}")
        source_record = VMRecord(**registry[source])
        self.disks_dir.mkdir(parents=True, exist_ok=True)
        target_disk = (self.disks_dir / f"{target}.qcow2").resolve()
        self.runner.run(("qemu-img", "convert", "-p", "-O", "qcow2", source_record.disk, str(target_disk)), capture=False)
        record = VMRecord(target, str(target_disk), source_record.memory_mib, source_record.vcpus, self.uri)
        xml_path = self.state_dir / f"{target}.xml"
        xml_path.write_text(self._domain_xml(record, None), encoding="utf-8")
        try:
            self._virsh("define", str(xml_path))
        except Exception:
            target_disk.unlink(missing_ok=True)
            xml_path.unlink(missing_ok=True)
            raise
        registry[target] = asdict(record)
        self._save(registry)
        return record

    def delete(self, name: str, force: bool = False) -> None:
        self._validate_name(name)
        registry = self._load()
        record = registry.get(name)
        if not record:
            raise VMError(f"VM no registrada: {name}")
        if force:
            try:
                self._virsh("destroy", name)
            except VMError:
                pass
        self._virsh("undefine", name, "--snapshots-metadata")
        disk = Path(record["disk"])
        if disk.parent.resolve() != self.disks_dir.resolve():
            raise VMError(f"Se rechazó borrar un disco fuera del directorio administrado: {disk}")
        disk.unlink(missing_ok=True)
        (self.state_dir / f"{name}.xml").unlink(missing_ok=True)
        del registry[name]
        self._save(registry)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="vm-manager", description="Gestiona VMs reales mediante libvirt/QEMU-KVM")
    parser.add_argument("--uri", default=os.environ.get("QEMU_LABS_URI", DEFAULT_URI))
    parser.add_argument("--state-dir", type=Path, default=Path(os.environ.get("QEMU_LABS_STATE", "state")))
    sub = parser.add_subparsers(dest="command", required=True)
    create = sub.add_parser("create")
    create.add_argument("name")
    create.add_argument("--base-image", type=Path, required=True)
    create.add_argument("--cloud-init", type=Path)
    create.add_argument("--memory", type=int, default=2048)
    create.add_argument("--vcpus", type=int, default=2)
    sub.add_parser("list")
    for command in ("start", "stop", "delete"):
        item = sub.add_parser(command)
        item.add_argument("name")
        if command in ("stop", "delete"):
            item.add_argument("--force", action="store_true")
    snapshot = sub.add_parser("snapshot")
    snapshot.add_argument("name")
    snapshot.add_argument("snapshot_name")
    clone = sub.add_parser("clone")
    clone.add_argument("source")
    clone.add_argument("target")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    manager = VMManager(args.state_dir, args.uri)
    try:
        if args.command == "create":
            result = manager.create(args.name, args.base_image, args.memory, args.vcpus, args.cloud_init)
            print(json.dumps(asdict(result), indent=2))
        elif args.command == "list":
            print(manager.list())
        elif args.command == "start":
            print(manager.start(args.name))
        elif args.command == "stop":
            print(manager.stop(args.name, args.force))
        elif args.command == "snapshot":
            print(manager.snapshot(args.name, args.snapshot_name))
        elif args.command == "clone":
            print(json.dumps(asdict(manager.clone(args.source, args.target)), indent=2))
        elif args.command == "delete":
            manager.delete(args.name, args.force)
            print(f"VM eliminada: {args.name}")
    except VMError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
