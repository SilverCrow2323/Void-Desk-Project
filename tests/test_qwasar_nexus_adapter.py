from __future__ import annotations

from desk.qwasar.nexus_adapter import BASE_RINGS, compose_nexus_profile


def _workspace(workspace_id: str, order: int, **kwargs):
    return {"id": workspace_id, "order": order, **kwargs}


def test_missing_or_invalid_composition_keeps_exact_active_pygame_rings():
    rings, states = compose_nexus_profile(None)
    assert rings == BASE_RINGS
    assert rings == (
        (0,),
        (3, 5, 2, 6, 10, 11),
        (4, 1, 7, 8, 12, 13),
        (9,),
    )
    assert set(states) == set(range(14))
    for node_id in (1, 6, 10, 11, 12, 13):
        assert states[node_id]["workspace_id"] is None
    assert compose_nexus_profile({"workspaces": "not-a-list"})[0] == BASE_RINGS


def test_profile_reorders_hides_and_disables_only_mapped_workspaces():
    composition = {
        "profile": {"id": "custom", "name": "Custom"},
        "workspaces": [
            _workspace("start-session", 0),
            _workspace("uplink", 1),
            _workspace("the-forge", 2, enabled=False),
            _workspace("media-vault", 3, visible=False),
            _workspace("settings", 4),
            _workspace("rt-toolbox", 5, label="MY TOOLBOX"),
            _workspace("info-community", 6),
            _workspace("end-node", 7),
        ],
    }

    rings, states = compose_nexus_profile(composition)

    assert rings[0] == (0,)
    # UPLINK moves before THE FORGE; hidden MEDIA VAULT disappears.
    # WORKSHOP, GAMES and DEVELOP keep their established orbit slots.
    assert rings[1] == (5, 3, 6, 10, 11)
    # SETTINGS, MUOS APPS, TOOLBOX, COMMUNITY, INFO and OUTERDESK.
    assert rings[2] == (7, 1, 4, 12, 8, 13)
    assert rings[3] == (9,)
    assert states[3]["enabled"] is False
    assert states[3]["visible"] is True
    assert states[2]["visible"] is False
    assert states[4]["label"] == "MY TOOLBOX"
    assert set(states) == set(range(14))


def test_protected_start_and_end_are_never_hidden_or_disabled_by_adapter():
    composition = {
        "workspaces": [
            _workspace("start-session", 0, enabled=False, visible=False),
            _workspace("end-node", 7, enabled=False, visible=False),
            _workspace("the-forge", 1, enabled=False, visible=True),
        ]
    }

    rings, states = compose_nexus_profile(composition)

    assert rings[0] == (0,)
    assert rings[3] == (9,)
    assert states[0]["enabled"] is True
    assert states[0]["visible"] is True
    assert states[9]["enabled"] is True
    assert states[9]["visible"] is True
    assert states[3]["enabled"] is False
    assert states[3]["visible"] is True


def test_legacy_nodes_keep_stable_identity_and_are_not_reinterpreted():
    composition = {
        "workspaces": [
            _workspace("start-session", 0),
            _workspace("the-forge", 1),
            _workspace("uplink", 2),
            _workspace("media-vault", 3),
            _workspace("rt-toolbox", 4),
            _workspace("settings", 5),
            _workspace("info-community", 6),
            _workspace("end-node", 7),
        ]
    }

    rings, states = compose_nexus_profile(composition)
    assert rings[1] == (3, 5, 2, 6, 10, 11)
    assert rings[2] == (4, 1, 7, 12, 8, 13)
    for node_id in (1, 6, 10, 11, 12, 13):
        assert states[node_id]["workspace_id"] is None



def test_disabled_visible_nodes_are_skipped_without_changing_render_slots():
    from desk.qwasar.nexus_adapter import next_enabled_slot, resolve_enabled_slot

    ring = (3, 5, 2, 6)
    states = {
        3: {"enabled": False},
        5: {"enabled": True},
        2: {"enabled": False},
        6: {"enabled": True},
    }
    assert resolve_enabled_slot(ring, states, 0) == 1
    assert next_enabled_slot(ring, states, 1, 1) == 3
    assert next_enabled_slot(ring, states, 3, 1) == 1
    assert next_enabled_slot(ring, states, 1, -1) == 3


def test_hidden_nodes_are_removed_and_empty_orbits_are_skipped():
    from desk.qwasar.nexus_adapter import next_enabled_ring

    rings = ((0,), (), (4, 1), (9,))
    states = {
        0: {"enabled": True},
        4: {"enabled": False},
        1: {"enabled": False},
        9: {"enabled": True},
    }
    assert next_enabled_ring(rings, states, 0, 1) == 3
    assert next_enabled_ring(rings, states, 3, -1) == 0
    assert next_enabled_ring(rings, states, 0, -1) is None
