"""Direct software-surface output and event policy for muOS framebuffer devices."""


def init_muos_surface(pygame, fbdisplay, size):
    """Create an off-screen surface and attach it to the Linux framebuffer.

    This path intentionally avoids pygame.display.init() and set_mode(): some
    muOS H700 builds do not expose a usable SDL video backend, while fbdisplay
    writes the resulting pixels directly to /dev/fb0.
    """
    surface = pygame.Surface(size)
    if not fbdisplay.attach(surface):
        detail = fbdisplay.info() if hasattr(fbdisplay, "info") else "unknown"
        raise RuntimeError(
            "muOS framebuffer initialization failed (%s); "
            "check /dev/fb0 access and framebuffer geometry" % detail
        )
    return surface


def poll_muos_events(pygame, direct_fb=False):
    """Poll SDL window events only when an SDL display exists.

    In direct framebuffer mode, controls come from evinput/evdev and there is
    no SDL video/event queue to pump.
    """
    if direct_fb:
        return ()
    try:
        return pygame.event.get()
    except pygame.error:
        return ()



def init_muos_display(pygame, fbdisplay, size):
    """Prefer direct framebuffer; fall back to verified SDL+fbdisplay.

    The fallback preserves compatibility with firmware builds where direct
    Surface presentation is unavailable but SDL's dummy backend still works.
    Both paths require a successful framebuffer attach/write.
    """
    try:
        return init_muos_surface(pygame, fbdisplay, size), "direct"
    except Exception as direct_error:
        import os

        os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
        os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
        try:
            pygame.display.init()
            surface = pygame.display.set_mode(size)
            if not fbdisplay.attach(surface):
                raise RuntimeError(fbdisplay.info())
            return surface, "SDL fallback"
        except Exception as fallback_error:
            raise RuntimeError(
                "muOS framebuffer initialization failed; "
                "direct path: %s; SDL fallback: %s"
                % (str(direct_error)[:180], str(fallback_error)[:180])
            ) from fallback_error
