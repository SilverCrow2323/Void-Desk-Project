"""Fail-closed authentication and per-route capabilities for VOID BaseStation."""

from __future__ import annotations

import hmac
import re

_TOKEN_RE = re.compile(r"^[A-Za-z0-9_-]{32,}$")

ROUTE_CAPABILITIES = {
    ("GET", "/ping"): "status.read",
    ("GET", "/outbox"): "outbox.read",
    ("POST", "/notify"): "inbox.write",
    ("POST", "/outbox"): "outbox.write",
}
VALID_CAPABILITIES = frozenset(ROUTE_CAPABILITIES.values())


def valid_token(value: object) -> bool:
    """Accept only URL-safe pairing tokens with at least 32 characters."""
    return isinstance(value, str) and _TOKEN_RE.fullmatch(value) is not None


def valid_client_registry(clients: object) -> bool:
    """Require a non-empty, unambiguous client registry with explicit capabilities."""
    if not isinstance(clients, dict) or not clients:
        return False
    seen_tokens = set()
    for client_id, record in clients.items():
        if not isinstance(client_id, str) or not client_id.strip():
            return False
        if not isinstance(record, dict) or not valid_token(record.get("token")):
            return False
        token = record["token"]
        if token in seen_tokens:
            return False
        seen_tokens.add(token)
        capabilities = record.get("capabilities")
        if not isinstance(capabilities, list) or not capabilities:
            return False
        if any(not isinstance(cap, str) or cap not in VALID_CAPABILITIES for cap in capabilities):
            return False
    return True


def authorize_client(clients: object, supplied_token: object, method: str, path: str):
    """Return (client_id, allowed, reason); unknown routes fail closed."""
    required = ROUTE_CAPABILITIES.get((str(method).upper(), str(path)))
    if required is None:
        return None, False, "route_denied"
    if not valid_client_registry(clients) or not isinstance(supplied_token, str):
        return None, False, "auth_denied"
    for client_id, record in clients.items():
        if hmac.compare_digest(record["token"], supplied_token):
            if required in record["capabilities"]:
                return client_id, True, "authorized"
            return client_id, False, "capability_denied"
    return None, False, "auth_denied"
