# START SESSION — Desktop Environment Hub

The Start Session screen is a dedicated environment selector, not a generic action list.

## Profiles

| Environment | State in this build | Role |
|---|---|---|
| XFCE | Install + launch wired | Full desktop baseline |
| IceWM | Add-on install + launch wired | Lean window manager |
| LXDE | Add-on install + launch wired | Lightweight desktop |
| LXQt | Catalogue preview | Modern Qt desktop candidate |
| Openbox | Catalogue preview | Minimal custom-session foundation |
| Fluxbox | Catalogue preview | Compact classic window manager |
| MATE | Catalogue preview | Traditional full desktop candidate |

Only XFCE, IceWM and LXDE are backed by current service handlers and the shared
chroot launcher. The other four are deliberately marked PLANNED. Their cards
are not install buttons and must not be represented as ready-to-launch sessions.

## UI contract

- Two-column, thick-card layout with a distinct accent colour per environment.
- Installed profiles show a green check and retain their own environment colour.
- Missing and planned profiles use muted surfaces.
- Selecting a profile opens a focused detail overlay with role, features, estimated
  disk footprint, estimated memory use and currently available disk space.
- The selected profile has a rotating orbit particle around its mark.
- Background grid and particles remain low-contrast so text and focus stay legible.
- Keyboard/gamepad: D-pad to navigate, A to open/activate, Y to refresh, B to close/back.

## Honest limitations

The current marks are typographic placeholders, not upstream logo artwork. Disk and
RAM figures are planning estimates, not H700 measurements. The current service does
not yet expose environment removal, forced reinstall or per-environment update-check
handlers; the detail overlay labels those controls as not wired instead of issuing
commands that do not exist.

## Recommended next engineering steps

1. Add official upstream logo assets with their licences and attribution.
2. Add a shared package-operation broker for install/reinstall/remove/update, with
   progress events and confirmation for destructive removal.
3. Make the package resolver calculate disk requirements before installation.
4. Add per-profile compatibility metadata and verify actual launch commands in the
   chroot before advertising a profile as installable.
5. Add responsive visual captures for the 640x480 target and larger displays.
