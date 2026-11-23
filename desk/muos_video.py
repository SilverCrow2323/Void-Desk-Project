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
