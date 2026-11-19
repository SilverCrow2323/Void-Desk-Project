import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "operation_feedback", ROOT / "desk" / "operation_feedback.py"
)
feedback = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(feedback)


def test_known_heavy_tasks_use_full_screen():
    for kind in ("bootstrap", "package_install", "package_remove",
                 "package_upgrade", "storage_write", "backup_restore"):
        assert feedback.presentation_for(kind) == "screen"


def test_quick_actions_use_overlay():
    for kind in ("probe", "catalog_search", "status_check", "refresh"):
        assert feedback.presentation_for(kind, 0.5) == "overlay"


def test_duration_and_safety_promote_to_screen():
    assert feedback.presentation_for("unknown", 3) == "screen"
    assert feedback.presentation_for("unknown", 1, destructive=True) == "screen"
    assert feedback.presentation_for("unknown", 1, blocks_input=True) == "screen"


def test_unknown_work_promotes_after_budget():
    assert not feedback.should_promote(2.49)
    assert feedback.should_promote(2.5)
    assert feedback.should_promote(0, "package_install")


def test_missing_heartbeat_is_warning_threshold():
    assert not feedback.is_stalled(4.99)
    assert feedback.is_stalled(5)
