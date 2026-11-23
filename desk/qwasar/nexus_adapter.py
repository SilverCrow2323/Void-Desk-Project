"""Profile-to-legacy-node adapter for the active Pygame NEXUS renderer.

The active desk.main App still uses the ten-node layout (IDs 0-9). Keep this
mapping aligned with desk/main.py, not the separate/newer const.py layout.
QWASAR workspace IDs control only the mapped nodes; legacy destinations stay
in their established orbit and slot.
"""
from __future__ import annotations

from collections.abc import Mapping, Sequence
from typing import Any


# Exact active Pygame layout from desk/main.py:
# inner: START SESSION; mid: FORGE, UPLINK, MEDIA, WORKSHOP;
# outer: RT:TOOLBOX, MUOS APPS, SETTINGS, INFO; far: END NODE.
BASE_RINGS: tuple[tuple[int, ...], ...] = (
    (0,),
    (3, 5, 2, 6),
    (4, 1, 7, 8),
    (9,),
)

WORKSPACE_BY_NODE: dict[int, str] = {
    0: "start-session",
    3: "the-forge",
    5: "uplink",
    2: "media-vault",
    4: "rt-toolbox",
    7: "settings",
    8: "info-community",
    9: "end-node",
}

PROTECTED_WORKSPACES = frozenset({"start-session", "end-node"})

# Legacy-only nodes keep stable positions between profile-controlled entries.
# The numeric values intentionally leave room for the QWASAR order indices.
LEGACY_SORT_ORDER: dict[int, float] = {
    6: 3.5,  # WORKSHOP, mid orbit
    1: 4.5,  # MUOS APPS, outer orbit
}


def compose_nexus_profile(
    composition: Mapping[str, Any] | None,
) -> tuple[tuple[tuple[int, ...], ...], dict[int, dict[str, Any]]]:
    """Return effective ring IDs and per-node display/activation state.

    Invalid/missing snapshots fall back to the exact active legacy layout.
    Only mapped QWASAR workspaces are reordered/hidden. All legacy nodes
    retain their identity. START SESSION and END NODE remain recovery anchors.
    """
    states: dict[int, dict[str, Any]] = {}
    base_positions = {
        node_id: (ring_index, position)
        for ring_index, ring in enumerate(BASE_RINGS)
        for position, node_id in enumerate(ring)
    }
    for node_id, (ring_index, position) in base_positions.items():
        states[node_id] = {
            "workspace_id": WORKSPACE_BY_NODE.get(node_id),
            "enabled": True,
            "visible": True,
            "label": None,
            "order": LEGACY_SORT_ORDER.get(node_id, float(position)),
        }

    if not isinstance(composition, Mapping):
        return BASE_RINGS, states

    raw_workspaces = composition.get("workspaces")
    if not isinstance(raw_workspaces, Sequence) or isinstance(
        raw_workspaces, (str, bytes)
    ):
        return BASE_RINGS, states

    by_id: dict[str, Mapping[str, Any]] = {}
    for workspace in raw_workspaces:
        if isinstance(workspace, Mapping):
            workspace_id = workspace.get("id")
            if isinstance(workspace_id, str):
                by_id[workspace_id] = workspace

    for node_id, workspace_id in WORKSPACE_BY_NODE.items():
        workspace = by_id.get(workspace_id)
        if workspace is None:
            continue
        state = states[node_id]
        is_protected = workspace_id in PROTECTED_WORKSPACES
        state["enabled"] = (
            True if is_protected else workspace.get("enabled") is not False
        )
        state["visible"] = (
            True if is_protected else workspace.get("visible") is not False
        )
        label = workspace.get("label")
        state["label"] = (
            label if isinstance(label, str) and label.strip() else None
        )
        order = workspace.get("order")
        if isinstance(order, (int, float)) and not isinstance(order, bool):
            state["order"] = float(order)

    rings: list[tuple[int, ...]] = []
    for base_ring in BASE_RINGS:
        visible_ids = [
            node_id for node_id in base_ring if states[node_id]["visible"]
        ]
        visible_ids.sort(
            key=lambda node_id: (
                states[node_id]["order"],
                base_positions[node_id][1],
            )
        )
        rings.append(tuple(visible_ids))

    return tuple(rings), states
