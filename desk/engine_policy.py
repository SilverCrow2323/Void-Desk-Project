"""Shared, fail-safe frontend selection policy for Void Desk."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

DEFAULT_ENGINE = "py"
VALID_ENGINES = frozenset({"py", "love"})


def resolve_engine_config(config: Any) -> str:
    """Preserve an explicit supported choice; default malformed/missing values to Pygame."""
    if not isinstance(config, dict):
        return DEFAULT_ENGINE
    engine = config.get("engine", DEFAULT_ENGINE)
    return engine if isinstance(engine, str) and engine in VALID_ENGINES else DEFAULT_ENGINE


def load_engine(config_path: str | Path) -> str:
    """Read a local engine preference without making startup depend on valid JSON."""
    try:
        config = json.loads(Path(config_path).read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError):
        return DEFAULT_ENGINE
    return resolve_engine_config(config)
