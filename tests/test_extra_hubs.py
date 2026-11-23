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
    assert app.info_title == "COLLEZIONI"


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
