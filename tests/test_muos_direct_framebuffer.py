from desk.muos_video import init_muos_surface, poll_muos_events


class _FakeSurface:
    def __init__(self, size):
        self.size = size


class _ForbiddenDisplay:
    def init(self):
        raise AssertionError("SDL display must not be initialized on muOS")

    def set_mode(self, size):
        raise AssertionError("SDL set_mode must not be used on muOS")


class _FakeEvents:
    def __init__(self, error=None):
        self.error = error
        self.called = False

    def get(self):
        self.called = True
        if self.error:
            raise self.error
        return ("event",)


class _FakePygame:
    error = RuntimeError

    def __init__(self, event_error=None):
        self.created = None
        self.display = _ForbiddenDisplay()
        self.event = _FakeEvents(event_error)

    def Surface(self, size):
        self.created = _FakeSurface(size)
        return self.created


class _FakeFramebuffer:
    def __init__(self, available=True):
        self.available = available
        self.attached = None

    def attach(self, surface):
        self.attached = surface
        return self.available

    def info(self):
        return "fb: test"


def test_muos_surface_uses_direct_framebuffer_without_sdl_display():
    pygame = _FakePygame()
    fb = _FakeFramebuffer()
    surface = init_muos_surface(pygame, fb, (640, 480))
    assert surface is pygame.created
    assert surface.size == (640, 480)
    assert fb.attached is surface


def test_muos_surface_fails_loudly_when_framebuffer_is_unavailable():
    pygame = _FakePygame()
    fb = _FakeFramebuffer(available=False)
    try:
        init_muos_surface(pygame, fb, (640, 480))
    except RuntimeError as exc:
        assert "framebuffer initialization failed" in str(exc)
    else:
        raise AssertionError("expected framebuffer initialization failure")


def test_direct_fb_does_not_touch_sdl_event_queue():
    pygame = _FakePygame()
    assert poll_muos_events(pygame, direct_fb=True) == ()
    assert not pygame.event.called


def test_desktop_mode_keeps_sdl_event_queue():
    pygame = _FakePygame()
    assert poll_muos_events(pygame, direct_fb=False) == ("event",)
    assert pygame.event.called



class _FallbackDisplay:
    def __init__(self):
        self.initialized = False
        self.surface = None

    def init(self):
        self.initialized = True

    def set_mode(self, size):
        if not self.initialized:
            raise AssertionError("SDL display must be initialized first")
        self.surface = _FakeSurface(size)
        return self.surface


class _FallbackPygame(_FakePygame):
    def __init__(self):
        super().__init__()
        self.display = _FallbackDisplay()


class _SequencedFramebuffer:
    def __init__(self, outcomes):
        self.outcomes = list(outcomes)
        self.calls = 0

    def attach(self, surface):
        self.calls += 1
        return self.outcomes.pop(0)

    def info(self):
        return "fb: simulated"


def test_muos_display_falls_back_only_after_direct_path_failure():
    from desk.muos_video import init_muos_display

    pygame = _FallbackPygame()
    fb = _SequencedFramebuffer([False, True])

    surface, mode = init_muos_display(pygame, fb, (640, 480))

    assert mode == "SDL fallback"
    assert pygame.display.initialized
    assert surface is pygame.display.surface
    assert fb.calls == 2


def test_muos_display_fails_if_both_verified_framebuffer_paths_fail():
    from desk.muos_video import init_muos_display

    pygame = _FallbackPygame()
    fb = _SequencedFramebuffer([False, False])

    try:
        init_muos_display(pygame, fb, (640, 480))
    except RuntimeError as exc:
        assert "direct path" in str(exc)
        assert "SDL fallback" in str(exc)
    else:
        raise AssertionError("expected both framebuffer paths to fail")


def test_muos_display_prefers_direct_framebuffer_when_available():
    from desk.muos_video import init_muos_display

    pygame = _FakePygame()
    fb = _FakeFramebuffer(available=True)

    surface, mode = init_muos_display(pygame, fb, (640, 480))

    assert mode == "direct"
    assert surface is pygame.created
    assert fb.attached is surface
