# Void Desk — Operation feedback system

## The rule

Void Desk must never leave a user guessing whether the application is working, waiting for input, or frozen. Every asynchronous action reports a visible state, and every operation has a clear completion or failure outcome.

## Two presentation levels

### Dedicated full-screen progress scene

Use for long, invasive, destructive, or multi-stage operations: first-boot bootstrap; desktop/environment installation; package install, remove and upgrade; system updates and dependency transactions; storage writes, backup/restore and firmware operations; and any workflow that blocks navigation or takes ownership of input.

Show operation title, current phase, current item, per-item progress where available, total progress where meaningful, elapsed time, and concise live log. If the backend cannot provide a percentage, show an indeterminate animation. Never invent or smoothly fake a percentage.

### Lightweight overlay

Use for quick, non-destructive actions that should not interrupt the current screen: probes, status checks, catalogue searches, refreshes, quick toggles and short connection actions. The overlay stays attached to the current screen, has a compact spinner/progress indicator and short verb phrase, and disappears on completion. It must not steal focus unless input is genuinely unavailable.

## Promotion and anti-freeze behaviour

- Unknown-duration work starts as an overlay.
- Promote it to the dedicated scene after 2.5 seconds.
- Known heavy/destructive/multi-stage tasks start full-screen immediately.
- Every worker emits a heartbeat at least once per second while alive.
- No heartbeat for 5 seconds raises a visible 'nessun aggiornamento' warning; it does not falsely declare the process dead.
- Show success briefly, then return to the originating screen.
- Keep failures visible until acknowledged; include a useful error and a route to the operation log.
- Preserve operation ID, originating screen and return route throughout promotion and completion.

## Progress contract

A worker event contains: operation_id, kind, phase, message, item, item_index, item_count, item_percent (optional), total_percent (optional), heartbeat, and terminal status (running/success/failed/cancelled).

Show percentages only when the worker can measure them. If only phases are known, render phase steps plus an indeterminate activity indicator. Offer cancellation only when the worker declares it safe.

## Implementation note

The current XFCE installer already owns a full-screen Pygame progress scene and parses APT status-fd events. The standalone safe APT manager still invokes APT without this shared presentation channel. Lightweight overlays also need an event bridge to the main Pygame loop; launching a second Pygame process is not an overlay and must not be used as a substitute.

This policy is the shared contract. Wiring all workers and the main event loop to one operation broker is a separate integration step; this document alone does not claim that every existing action has already been migrated.
