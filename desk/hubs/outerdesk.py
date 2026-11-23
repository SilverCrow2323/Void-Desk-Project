# -*- coding: utf-8 -*-
# ============================================================================
#  VOID DESK — OUTERDESK Hub
#  App standalone e strumenti portatili
# ============================================================================

from desk.hubs import HubMixin


class OuterdeskHub(HubMixin):
    """Outer-Desk: app standalone e strumenti portatili."""

    def __init__(self, app):
        self.app = app

    def apps(self):
        """Show the external-app catalogue without entering an unhandled state."""
        app = self.app
        app.info_title = "OUTERDESK"
        app.info_lines = [
            ("sec", "rocket", "APPLICAZIONI ESTERNE" if app.lang == "it"
             else "EXTERNAL APPLICATIONS"),
            ("kv", "", "Le app standalone vengono gestite dal catalogo esterno."
             if app.lang == "it" else
             "Standalone apps are managed by the external tools catalogue.",
             app.accent),
            ("kv", "", "Usa FORGE per installare gli strumenti supportati."
             if app.lang == "it" else
             "Use THE FORGE to install supported tools.", app.accent),
        ]
        app.scroll = 0
        app.push("info")
