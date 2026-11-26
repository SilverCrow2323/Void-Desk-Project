from __future__ import annotations
import importlib.util
import stat
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("voiddesk_muxapp_validator", ROOT / "tools" / "validate_muxapp.py")
assert spec and spec.loader
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)

def elf64_aarch64(payload: bytes = b"") -> bytes:
    header = bytearray(64)
    header[:4] = b"\x7fELF"
    header[4], header[5], header[6] = 2, 1, 1
    header[18:20] = (183).to_bytes(2, "little")
    return bytes(header) + payload

def valid_members() -> dict[str, tuple[bytes, int]]:
    files = {
        "Void-Desk/mux_launch.sh": (b"#!/bin/sh\n", 0o100755),
        "Void-Desk/voiddesk.py": (b"print('Void Desk')\n", 0o100644),
        "Void-Desk/love/main.lua": (b"print('love')\n", 0o100644),
        "Void-Desk/lib/love": (elf64_aarch64(b"liblove-11.5.so\0libluajit-5.1.so.2\0"), 0o100755),
        "Void-Desk/lib/liblove-11.5.so": (elf64_aarch64(b"\0" * (1024 * 1024)), 0o100644),
        "Void-Desk/lib/libluajit-5.1.so.2": (elf64_aarch64(), 0o100644),
    }
    return files

def write_archive(path: Path, members: dict[str, tuple[bytes, int]]) -> Path:
    with zipfile.ZipFile(path, "w") as archive:
        for name, (payload, mode) in members.items():
            info = zipfile.ZipInfo(name)
            info.external_attr = (stat.S_IFREG | mode) << 16
            archive.writestr(info, payload)
    return path

def test_accepts_valid_minimal_h700_package(tmp_path):
    archive = write_archive(tmp_path / "valid.muxapp", valid_members())
    assert validator.validate_archive(archive) == []

def test_rejects_parent_traversal(tmp_path):
    members = valid_members()
    members["../outside.txt"] = (b"escape", 0o100644)
    errors = validator.validate_archive(write_archive(tmp_path / "traversal.muxapp", members))
    assert any("unsafe archive member path" in error for error in errors)

def test_rejects_extra_top_level_directory(tmp_path):
    members = valid_members()
    members["Other/readme.txt"] = (b"unexpected", 0o100644)
    errors = validator.validate_archive(write_archive(tmp_path / "root.muxapp", members))
    assert any("unexpected top-level entry" in error for error in errors)

def test_rejects_symbolic_link_member(tmp_path):
    members = valid_members()
    members["Void-Desk/linked-file"] = (b"target", stat.S_IFLNK | 0o777)
    errors = validator.validate_archive(write_archive(tmp_path / "symlink.muxapp", members))
    assert any("symbolic links are not allowed" in error for error in errors)

def test_rejects_non_aarch64_runtime(tmp_path):
    members = valid_members()
    wrong = bytearray(members["Void-Desk/lib/love"][0])
    wrong[18:20] = (62).to_bytes(2, "little")
    members["Void-Desk/lib/love"] = (bytes(wrong), 0o100755)
    errors = validator.validate_archive(write_archive(tmp_path / "wrong-arch.muxapp", members))
    assert any("not AArch64" in error for error in errors)

def test_rejects_missing_runtime_library(tmp_path):
    members = valid_members()
    del members["Void-Desk/lib/libluajit-5.1.so.2"]
    errors = validator.validate_archive(write_archive(tmp_path / "missing.muxapp", members))
    assert any("required file missing" in error for error in errors)

def test_rejects_duplicate_archive_members(tmp_path):
    archive = tmp_path / "duplicate.muxapp"
    with zipfile.ZipFile(archive, "w") as package:
        for name, (payload, mode) in valid_members().items():
            info = zipfile.ZipInfo(name)
            info.external_attr = (stat.S_IFREG | mode) << 16
            package.writestr(info, payload)
        info = zipfile.ZipInfo("Void-Desk/voiddesk.py")
        info.external_attr = (stat.S_IFREG | 0o100644) << 16
        package.writestr(info, b"duplicate")
    errors = validator.validate_archive(archive)
    assert any("duplicate archive member" in error for error in errors)
