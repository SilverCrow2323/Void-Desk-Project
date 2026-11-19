"""Shared presentation policy for long-running Void Desk operations.

This module deliberately contains no UI or process-launching code so the
frontend and operation workers can agree on presentation without importing
Pygame into service processes.
"""

FULLSCREEN_KINDS = frozenset(("bootstrap", "package_install", "package_remove", "package_upgrade", "system_update", "environment_install", "storage_write", "backup_restore", "firmware", "multi_stage"))
OVERLAY_KINDS = frozenset(("refresh", "probe", "catalog_search", "status_check", "small_sync", "quick_toggle", "connect"))
OVERLAY_MAX_SECONDS = 2.0
PROMOTE_AFTER_SECONDS = 2.5
STALL_WARNING_SECONDS = 5.0
HEARTBEAT_SECONDS = 1.0
SUCCESS_VISIBLE_SECONDS = 1.5

def presentation_for(kind, estimated_seconds=None, destructive=False, multi_stage=False, blocks_input=False):
    kind = str(kind or "").strip().lower()
    if destructive or multi_stage or blocks_input or kind in FULLSCREEN_KINDS:
        return "screen"
    if kind in OVERLAY_KINDS:
        if estimated_seconds is not None:
            try:
                return "screen" if float(estimated_seconds) > OVERLAY_MAX_SECONDS else "overlay"
            except (TypeError, ValueError):
                pass
        return "overlay"
    if estimated_seconds is not None:
        try:
            if float(estimated_seconds) > OVERLAY_MAX_SECONDS:
                return "screen"
        except (TypeError, ValueError):
            pass
    return "overlay"

def should_promote(elapsed_seconds, kind=None):
    if kind and kind in FULLSCREEN_KINDS:
        return True
    try:
        return float(elapsed_seconds) >= PROMOTE_AFTER_SECONDS
    except (TypeError, ValueError):
        return False

def is_stalled(seconds_since_heartbeat):
    try:
        return float(seconds_since_heartbeat) >= STALL_WARNING_SECONDS
    except (TypeError, ValueError):
        return False
