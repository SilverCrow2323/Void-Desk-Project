from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

from desk.engine_policy import DEFAULT_ENGINE, load_engine, resolve_engine_config

ROOT = Path(__file__).resolve().parents[1]


def test_missing_or_invalid_config_defaults_to_pygame(tmp_path: Path) -> None:
    missing = tmp_path / "missing.json"
    malformed = tmp_path / "malformed.json"
    malformed.write_text("{not-json", encoding="utf-8")
    non_object = tmp_path / "array.json"
    non_object.write_text("[]", encoding="utf-8")

    assert DEFAULT_ENGINE == "py"
    assert load_engine(missing) == "py"
    assert load_engine(malformed) == "py"
    assert load_engine(non_object) == "py"


def test_explicit_supported_engine_is_preserved() -> None:
    assert resolve_engine_config({"engine": "py"}) == "py"
    assert resolve_engine_config({"engine": "love"}) == "love"


def test_unknown_or_malformed_engine_values_default_to_pygame() -> None:
    for value in (None, 1, "", "pygame", "LOVE", "unknown"):
        assert resolve_engine_config({"engine": value}) == "py"
    assert resolve_engine_config(None) == "py"
    assert resolve_engine_config("love") == "py"


def test_resolver_cli_prints_the_validated_choice(tmp_path: Path) -> None:
    config = tmp_path / "desk_config.json"
    config.write_text(json.dumps({"engine": "love"}), encoding="utf-8")
    result = subprocess.run(
        [sys.executable, str(ROOT / "bin" / "resolve_engine.py"), str(config)],
        check=True,
        capture_output=True,
        text=True,
    )
    assert result.stdout.strip() == "love"


def test_handheld_launcher_uses_the_shared_resolver() -> None:
    launcher = (ROOT / "mux_launch.sh").read_text(encoding="utf-8")
    assert 'bin/resolve_engine.py' in launcher
    assert "get('engine','love')" not in launcher
    assert "print('love')" not in launcher


def test_pygame_identifier_and_frontend_defaults_are_consistent() -> None:
    assert resolve_engine_config({"engine": "pygame"}) == "py"
    assert '"engine": "py"' in (ROOT / "voiddesk.py").read_text(encoding="utf-8")
    assert 'cfg.get("engine", "py")' in (ROOT / "desk" / "hubs" / "settings.py").read_text(encoding="utf-8")
    assert 'engine = "py"' in (ROOT / "love" / "core" / "config.lua").read_text(encoding="utf-8")
    assert 'get("engine", "py")' in (ROOT / "love" / "scenes" / "hub_settings.lua").read_text(encoding="utf-8")
    assert "manifest identifier `pygame` is normalized" in (ROOT / "docs" / "QWASAR_BOOT_AND_SESSION_MODEL.md").read_text(encoding="utf-8")
