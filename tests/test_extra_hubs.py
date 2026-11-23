from pathlib import Path
from desk.hubs.games import GamesHub
from desk.hubs.develop import DevelopHub
from desk.hubs.community import CommunityHub
from desk.hubs.outerdesk import OuterdeskHub


class FakeApp:
    def __init__(self, data):
        self.DATA = str(data)
        self.lang = "en"
        self.accent = (10, 20, 30)
        self.states = []
        self.info_lines = []
        self.info_title = ""
        self.fm_paths = []
        self.notifications = []

    def push(self, state):
        self.states.append(state)

    def fm_open(self, **kwargs):
        self.fm_paths.append(kwargs.get("start_path"))

    def notify(self, *args):
        self.notifications.append(args)


def test_games_collections_opens_a_real_info_view(tmp_path):
    app = FakeApp(tmp_path)
    GamesHub(app).collections()
    assert app.states == ["info"]
    assert app.info_title == "COLLECTIONS"


def test_develop_repl_opens_existing_python_console(tmp_path):
    app = FakeApp(tmp_path)
    DevelopHub(app).repl()
    assert app.states == ["pyrepl"]
    assert app.py_ns == {}
    assert app.py_out[0].startswith("Python ")


def test_community_share_creates_and_opens_shared_directory(tmp_path):
    app = FakeApp(tmp_path)
    CommunityHub(app).share()
    assert app.fm_paths == [str(tmp_path / "shared")]
    assert (tmp_path / "shared").is_dir()


def test_outerdesk_catalogue_uses_supported_info_state(tmp_path):
    app = FakeApp(tmp_path)
    OuterdeskHub(app).apps()
    assert app.states == ["info"]
    assert app.info_title == "OUTERDESK"



def test_external_process_environment_does_not_leak_pygame_runtime(monkeypatch):
    from desk.hubs import HubMixin

    root = Path(__file__).resolve().parents[1]
    monkeypatch.setenv(
        "LD_LIBRARY_PATH",
        str(root / "runtime" / "pygame.libs") + ":" +
        str(root / "lib") + ":/system/lib",
    )
    monkeypatch.setenv("PYTHONPATH", "/voiddesk:/voiddesk/runtime")
    monkeypatch.setenv("VOIDDESK_DIRECT_FB", "1")
    monkeypatch.setenv("VOIDCAST_FB_DEV", "/dev/fb0")

    env = HubMixin().external_env()

    assert env["LD_LIBRARY_PATH"] == "/system/lib"
    assert "PYTHONPATH" not in env
    assert "VOIDDESK_DIRECT_FB" not in env
    assert "VOIDCAST_FB_DEV" not in env


def test_portmaster_launch_uses_clean_environment_and_detached_session(
    monkeypatch, tmp_path
):
    import subprocess
    from desk.hubs.games import GamesHub

    app = FakeApp(tmp_path)
    app.running = True
    app.exit_code = None
    app.handoff = lambda message: None
    launched = {}

    monkeypatch.setattr(
        "desk.hubs.games.os.path.exists",
        lambda path: path == "/mnt/mmc/MUOS/PortMaster/PortMaster.sh",
    )

    def fake_popen(args, **kwargs):
        launched["args"] = args
        launched["kwargs"] = kwargs
        return object()

    monkeypatch.setattr(subprocess, "Popen", fake_popen)
    root = Path(__file__).resolve().parents[1]
    monkeypatch.setenv(
        "LD_LIBRARY_PATH",
        str(root / "runtime" / "pygame.libs") + ":" +
        str(root / "lib") + ":/system/lib",
    )
    monkeypatch.setenv("PYTHONPATH", "/voiddesk:/voiddesk/runtime")
    monkeypatch.setenv("VOIDDESK_DIRECT_FB", "1")

    GamesHub(app).portmaster()

    assert launched["args"] == [
        "/bin/sh", "/mnt/mmc/MUOS/PortMaster/PortMaster.sh"
    ]
    assert launched["kwargs"]["start_new_session"] is True
    assert launched["kwargs"]["env"]["LD_LIBRARY_PATH"] == "/system/lib"
    assert "PYTHONPATH" not in launched["kwargs"]["env"]
    assert "VOIDDESK_DIRECT_FB" not in launched["kwargs"]["env"]
    assert app.running is False
    assert app.exit_code == 0


def test_community_browser_launch_uses_clean_environment(monkeypatch, tmp_path):
    import shutil
    import subprocess
    from desk.hubs.community import CommunityHub

    app = FakeApp(tmp_path)
    launched = {}

    monkeypatch.setattr(shutil, "which", lambda name: "chromium")
    monkeypatch.setattr(
        subprocess, "Popen",
        lambda args, **kwargs: launched.update(args=args, kwargs=kwargs),
    )
    root = Path(__file__).resolve().parents[1]
    monkeypatch.setenv(
        "LD_LIBRARY_PATH",
        str(root / "runtime" / "pygame.libs") + ":" +
        str(root / "lib") + ":/system/lib",
    )
    monkeypatch.setenv("VOIDDESK_DIRECT_FB", "1")

    CommunityHub(app).forum()

    assert launched["args"] == ["chromium", "https://community.muos.dev"]
    assert launched["kwargs"]["start_new_session"] is True
    assert launched["kwargs"]["env"]["LD_LIBRARY_PATH"] == "/system/lib"
    assert "VOIDDESK_DIRECT_FB" not in launched["kwargs"]["env"]
