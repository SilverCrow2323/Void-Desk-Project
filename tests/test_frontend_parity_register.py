from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAP = (ROOT / "docs" / "LOVE_FRONTEND_GAP_REGISTER.md").read_text(encoding="utf-8")
PYGAME = (ROOT / "desk" / "main.py").read_text(encoding="utf-8")


def test_every_nexus_destination_has_an_explicit_love_status():
    destinations = (
        "START SESSION", "THE FORGE", "UPLINK", "MEDIA VAULT", "WORKSHOP",
        "TOOLBOX", "MUOS APPS", "SETTINGS", "INFO", "END NODE",
        "GAMES", "DEVELOP", "COMMUNITY", "OUTERDESK", "LEGACY",
    )
    for destination in destinations:
        assert destination in GAP


def test_pygame_extension_routes_are_tracked_as_hidden_love_destinations():
    for destination in ("GAMES", "DEVELOP", "COMMUNITY", "OUTERDESK"):
        assert destination in PYGAME
        assert f"- {destination}" in GAP


def test_release_gate_keeps_pygame_as_reference_until_love_parity():
    assert "Pygame as the reference frontend" in GAP
    assert "parity for the declared release scope is demonstrated" in GAP
    assert "physical RG35XX-H hardware" in GAP
