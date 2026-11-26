from __future__ import annotations

import importlib.util
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("voiddesk_evinput", ROOT / "desk" / "evinput.py")
evinput = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(evinput)


def test_andromeda_start_and_r2_have_distinct_physical_codes(monkeypatch):
    monkeypatch.setenv("MUOS_VERSION", "muOS Andromeda 2606.0")
    assert evinput.resolve_profile("auto") == "andromeda"
    evinput.set_profile("andromeda")
    assert evinput.KEYMAP[315] == "START"
    assert evinput.KEYMAP[313] == "R2"
    assert evinput.KEYMAP[316] == "MENU"
    assert evinput.KEYMAP[315] != evinput.KEYMAP[313]


def test_non_andromeda_profile_retains_legacy_button_layout():
    evinput.set_profile("not_andromeda")
    assert evinput.KEYMAP[315] == "MENU"
    assert evinput.KEYMAP[316] == "START"
    assert evinput.KEYMAP[317] == "L2"
    assert evinput.KEYMAP[318] == "R2"


def test_auto_profile_does_not_infer_andromeda_from_unknown_release(monkeypatch):
    monkeypatch.setenv("MUOS_VERSION", "muOS unknown release")
    assert evinput.resolve_profile("auto") == "not_andromeda"


def test_explicit_profile_override_is_deterministic(monkeypatch):
    monkeypatch.setenv("MUOS_VERSION", "muOS unknown release")
    assert evinput.resolve_profile("andromeda") == "andromeda"
    assert evinput.resolve_profile("not_andromeda") == "not_andromeda"
