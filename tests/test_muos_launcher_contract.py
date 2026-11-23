from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_muos_launcher_enables_direct_framebuffer_and_keeps_pygame_diagnostics():
    launcher = (ROOT / "mux_launch.sh").read_text(encoding="utf-8")
    assert "export VOIDDESK_DIRECT_FB=1" in launcher
    assert "export VOIDCAST_FB_DEV=/dev/fb0" in launcher
    assert "export VOIDCAST_FB_SYSFS=/sys/class/graphics/fb0" in launcher
    assert "unset SDL_VIDEODRIVER" in launcher
    assert 'PYTHONPATH="$APP_DIR:$APP_DIR/runtime' in launcher
    assert "runtime/pygame.libs" in launcher
    assert "keeping Pygame selected for diagnostics" in launcher
    assert "falling back to LOVE engine" not in launcher
    assert "launching LÖVE frontend as fallback" not in launcher


def test_pygame_direct_framebuffer_path_is_used_only_on_muos():
    main = (ROOT / "desk" / "main.py").read_text(encoding="utf-8")
    assert 'os.environ.get("VOIDDESK_DIRECT_FB") != "1"' in main
    assert "init_muos_display(" in main
    assert "pygame, fbdisplay, (W, H)" in main
    assert "poll_muos_events(" in main


def test_fbdisplay_reports_write_failures_instead_of_silently_swallowing_them():
    source = (ROOT / "desk" / "fbdisplay.py").read_text(encoding="utf-8")
    assert 'self.error = "%s: %s"' in source
    assert 'raise RuntimeError("fbdisplay: "' in source
    assert "initial framebuffer write failed" in source
