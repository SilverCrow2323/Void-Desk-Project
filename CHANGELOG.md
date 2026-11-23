# Void Desk changelog

## Unreleased — v10.5.4-NEXUS candidate (23 November 2026)

This is a candidate summary, not a published release. The latest public handheld package remains v10.2.0.

### Added

- QWASAR profile composition for the Pygame NEXUS workspaces: ordering, visibility and enabled state.
- Full 14-destination Pygame NEXUS navigation, including GAMES, DEVELOP, COMMUNITY and OUTERDESK.
- Tree of Life orbital overlay with disabled-branch styling and fail-open renderer handling.
- muOS H700 direct framebuffer presentation with an initial write check and verified SDL/framebuffer fallback.
- Offline-first Pygame runtime bootstrap using bundled CPython 3.11/aarch64 archives, safe extraction and ABI validation.
- External tool routing for shell, LÖVE and portable-VoidCast launcher types.
- A physical H700 release smoke-test checklist.

### Changed

- Pygame remains the default/reference handheld frontend; LÖVE remains experimental.
- External processes no longer inherit Void Desk's bundled Pygame/SDL library paths, Python paths or direct-framebuffer flags. Host library paths are preserved, and the LÖVE path receives only its required application library directory.
- The NEXUS profile adapter preserves six legacy destination IDs and protects START SESSION / END NODE as recovery anchors.

### Fixed

- Restored the visible notification queue and bounded notification history.
- Removed a duplicate _media_panel_toggle method and restored the external-tool launcher as its own App method.
- Fixed external tool dispatch to respect declared shell, LÖVE and portable-VoidCast launcher types and hand off the display before leaving Void Desk.
- Prevented disabled or hidden QWASAR workspaces from remaining valid navigation/activation targets.

### Validation status

- PR #100, #101 and #102 are merged.
- PR #102 exact-head CI passed: 305 Python tests, 3 subtests, repository integrity audit, Pygame captures, LÖVE/Rt:Tailscale-M integration, QEMU checks and .muxapp/.deb builds with checksums.
- Physical H700/RG35XXSP validation is still pending.
- Issues #1, #2, #42 and #78 remain open. BaseStation stays a PC-only prototype and is not claimed as a completed paired service.
- No v10.5.4 tag or public release has been created.
