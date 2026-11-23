"""Regression checks for authenticated HTTPS package transport in desktop chroots."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
APT_ENTRYPOINTS = (
    "bin/xfce_bootstrap.py",
    "bin/env_install.py",
    "bin/xfce_update.py",
    "bin/xfce_install.py",
    "bin/xfce_launch.sh",
)


def test_chroot_apt_never_disables_tls_peer_or_hostname_verification() -> None:
    insecure_options = (
        "Acquire::https::Verify-Peer=false",
        "Acquire::https::Verify-Host=false",
    )
    for relative_path in APT_ENTRYPOINTS:
        source = (ROOT / relative_path).read_text(encoding="utf-8")
        for option in insecure_options:
            assert option not in source, f"{relative_path} disables TLS verification: {option}"


def test_bootstrap_installs_ca_roots_and_keeps_ipv4_compatibility() -> None:
    bootstrap = (ROOT / "bin" / "xfce_bootstrap.py").read_text(encoding="utf-8")
    assert "ca-certificates" in bootstrap
    assert "Acquire::ForceIPv4=true" in bootstrap


def test_apt_update_subcommands_remain_after_tls_hardening() -> None:
    for relative_path in ("bin/xfce_install.py", "bin/xfce_update.py"):
        source = (ROOT / relative_path).read_text(encoding="utf-8")
        assert re.search(r'"-o Acquire::ForceIPv4=true "\\s+"update"', source), relative_path
