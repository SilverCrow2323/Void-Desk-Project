"""Regression checks for authenticated HTTPS package transport in desktop chroots."""

import os
import subprocess
from pathlib import Path

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
        assert '"-o Acquire::ForceIPv4=true "' in source
        assert '"update"],' in source, relative_path


def test_ci_apt_installer_normalizes_runner_mirrors_without_disabling_tls(tmp_path: Path) -> None:
    apt_root = tmp_path / "apt"
    sources_d = apt_root / "sources.list.d"
    sources_d.mkdir(parents=True)
    sources_list = apt_root / "sources.list"
    sources_list.write_text(
        "deb http://us-east-2.ec2.archive.ubuntu.com/ubuntu noble main\n",
        encoding="utf-8",
    )
    deb822 = sources_d / "ubuntu.sources"
    deb822.write_text(
        "Types: deb\nURIs: http://us-east-2.ec2.archive.ubuntu.com/ubuntu\n"
        "Suites: noble\nComponents: main\n",
        encoding="utf-8",
    )
    mirror_list = apt_root / "apt-mirrors.txt"
    mirror_list.write_text(
        "azure.archive.ubuntu.com\nus-east-2.ec2.archive.ubuntu.com\nmirror.example.invalid\n",
        encoding="utf-8",
    )

    environment = os.environ.copy()
    environment["QWASAR_CI_APT_SOURCES_ROOT"] = str(apt_root)
    environment["QWASAR_CI_APT_NORMALIZE_ONLY"] = "1"
    result = subprocess.run(
        ["bash", str(ROOT / "tools" / "ci_apt_install.sh"), "unused-package"],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )

    assert result.returncode == 0, result.stderr
    assert "https://archive.ubuntu.com/ubuntu" in sources_list.read_text(encoding="utf-8")
    assert "https://archive.ubuntu.com/ubuntu" in deb822.read_text(encoding="utf-8")
    remaining_mirrors = mirror_list.read_text(encoding="utf-8")
    assert "azure.archive.ubuntu.com" not in remaining_mirrors
    assert "us-east-2.ec2.archive.ubuntu.com" not in remaining_mirrors
    assert "mirror.example.invalid" in remaining_mirrors

    script = (ROOT / "tools" / "ci_apt_install.sh").read_text(encoding="utf-8")
    assert "Acquire::https::Verify-Peer=false" not in script
    assert "Acquire::https::Verify-Host=false" not in script
