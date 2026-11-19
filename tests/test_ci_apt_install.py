"""Regression tests for the bounded CI APT installer mirror selection."""

import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "ci_apt_install.sh"


def executable(path: Path, content: str) -> Path:
    path.write_text(content, encoding="utf-8")
    path.chmod(0o755)
    return path


def run_helper(tmp_path: Path, mirror_host: str):
    fakebin = tmp_path / "bin"
    fakebin.mkdir()
    mirror_list = tmp_path / "apt-mirrors.txt"
    mirror_list.write_text(
        f"http://{mirror_host}/ubuntu\n"
        "http://security.ubuntu.com/ubuntu\n",
        encoding="utf-8",
    )
    apt_log = tmp_path / "apt.log"

    executable(fakebin / "sudo", "#!/bin/sh\nexec \"$@\"\n")
    executable(
        fakebin / "apt-get",
        "#!/bin/sh\nprintf '%s\\n' \"$*\" >> \"$APT_LOG\"\nexit 0\n",
    )

    env = os.environ.copy()
    env.update({
        "PATH": str(fakebin) + os.pathsep + "/usr/bin:/bin",
        "QWASAR_CI_APT_MIRROR_LIST": str(mirror_list),
        "APT_LOG": str(apt_log),
    })
    result = subprocess.run(
        ["bash", str(SCRIPT), "shellcheck", "luajit"],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    return result, mirror_list, apt_log


def test_aws_regional_archive_is_rewritten_to_global_archive(tmp_path):
    result, mirror_list, apt_log = run_helper(
        tmp_path, "us-east-2.ec2.archive.ubuntu.com"
    )

    assert result.returncode == 0, result.stderr
    mirrors = mirror_list.read_text(encoding="utf-8")
    assert "http://archive.ubuntu.com/ubuntu" in mirrors
    assert "us-east-2.ec2.archive.ubuntu.com" not in mirrors
    assert "security.ubuntu.com" in mirrors
    calls = apt_log.read_text(encoding="utf-8").splitlines()
    assert len(calls) == 2
    assert calls[0].startswith("update -qq ")
    assert calls[1].startswith("install -y ")
    assert all("Acquire::http::Timeout=20" in call for call in calls)


def test_azure_archive_is_rewritten_to_global_archive(tmp_path):
    result, mirror_list, _apt_log = run_helper(
        tmp_path, "azure.archive.ubuntu.com"
    )

    assert result.returncode == 0, result.stderr
    mirrors = mirror_list.read_text(encoding="utf-8")
    assert "http://archive.ubuntu.com/ubuntu" in mirrors
    assert "azure.archive.ubuntu.com" not in mirrors
    assert "security.ubuntu.com" in mirrors
