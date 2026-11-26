from __future__ import annotations

import importlib.util
import os
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("voiddesk_evinput", ROOT / "desk" / "evinput.py")
evinput = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(evinput)


class EvdevProfileTests(unittest.TestCase):
    def test_andromeda_start_and_r2_have_distinct_physical_codes(self):
        with patch.dict(os.environ, {"MUOS_VERSION": "muOS Andromeda 2606.0"}):
            self.assertEqual(evinput.resolve_profile("auto"), "andromeda")
            evinput.set_profile("andromeda")
            self.assertEqual(evinput.KEYMAP[315], "START")
            self.assertEqual(evinput.KEYMAP[313], "R2")
            self.assertEqual(evinput.KEYMAP[316], "MENU")
            self.assertNotEqual(evinput.KEYMAP[315], evinput.KEYMAP[313])

    def test_non_andromeda_profile_retains_legacy_button_layout(self):
        evinput.set_profile("not_andromeda")
        self.assertEqual(evinput.KEYMAP[315], "MENU")
        self.assertEqual(evinput.KEYMAP[316], "START")
        self.assertEqual(evinput.KEYMAP[317], "L2")
        self.assertEqual(evinput.KEYMAP[318], "R2")

    def test_auto_profile_does_not_infer_andromeda_from_unknown_release(self):
        with patch.dict(os.environ, {"MUOS_VERSION": "muOS unknown release"}):
            self.assertEqual(evinput.resolve_profile("auto"), "not_andromeda")

    def test_explicit_profile_override_is_deterministic(self):
        with patch.dict(os.environ, {"MUOS_VERSION": "muOS unknown release"}):
            self.assertEqual(evinput.resolve_profile("andromeda"), "andromeda")
            self.assertEqual(evinput.resolve_profile("not_andromeda"), "not_andromeda")


if __name__ == "__main__":
    unittest.main(verbosity=2)
