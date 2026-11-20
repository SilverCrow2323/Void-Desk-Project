#!/usr/bin/env python3
"""Print the validated engine selected for a local Void Desk configuration."""

from __future__ import annotations

import sys
from pathlib import Path

APP_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(APP_ROOT))

from desk.engine_policy import load_engine  # noqa: E402


def main() -> int:
    config_path = Path(sys.argv[1]) if len(sys.argv) > 1 else APP_ROOT / "data" / "desk_config.json"
    print(load_engine(config_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
