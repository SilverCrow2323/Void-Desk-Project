# Void Desk 10.5.4-NEXUS — release readiness

> Status snapshot: 23 November 2026, after PRs #100, #101 and #102 were merged. This is an engineering gate, **not a release announcement**.
>
> The latest published handheld package remains **v10.2.0** (11 August 2026). The v10.5.4-NEXUS candidate is integrated on main, but it is not tagged or published. v12 remains a blueprint.

## Release policy

- Pygame is the reference handheld frontend. LÖVE remains experimental and is not feature-equivalent.
- A green source CI is necessary, but it does not certify muOS/H700 hardware.
- Do not publish a release tag or binary until packaging, install/rollback and physical-device gates are evidenced.
- Do not advertise BaseStation as a completed SPDW Hub, secure paired service or remote-control product.
- The v10.5.4 release scope is the Pygame handheld path. The LÖVE feature stack remains separate and experimental.

## Integrated mainline baseline

| Change | Evidence | Status |
|---|---|---|
| PR #100 — QWASAR NEXUS adapter | Merged; exact-head CI #969 green | Integrated |
| PR #101 — H700 direct framebuffer and offline Pygame bootstrap | Merged; exact-head CI #974 green; main CI #975 green | Integrated; physical H700 validation pending |
| PR #102 — 14-node NEXUS, hub routes, Tree of Life, external launcher and notification repairs | Merged as commit 715e349; exact-head CI #989 green | Integrated |
| Mainline CI after PR #102 | Run #990 on merge commit 715e349 passed all three jobs | Green |
| Latest public package | v10.2.0, published 11 Aug 2026 | No v10.5.4 release asset exists |

### Candidate functionality now on main

- Pygame remains the default/reference frontend.
- NEXUS exposes 14 destinations: START SESSION, MUOS APPS, MEDIA VAULT, THE FORGE, RT:TOOLBOX, UPLINK, WORKSHOP, SETTINGS, INFO, END NODE, GAMES, DEVELOP, COMMUNITY and OUTERDESK.
- QWASAR profile composition controls the eight mapped workspaces. Six legacy destinations retain stable IDs; START SESSION and END NODE are protected recovery anchors.
- The Tree of Life is drawn behind orbital nodes. Hidden nodes have no live position; disabled nodes remain visible but are skipped by navigation. A drawing error is logged once and cannot break the main renderer.
- GAMES, DEVELOP and COMMUNITY dispatch to existing hub modules. OUTERDESK reads the external tool registry and supports its declared shell, LÖVE and portable-VoidCast launcher types.
- External programs are launched in detached sessions with Void Desk's Pygame/SDL library paths, Python paths and direct-framebuffer flags removed. Host library paths are preserved, and the LÖVE launcher receives only its required application library path.
- Notification delivery is restored to the visible queue and bounded history.
- muOS H700 launch prefers direct framebuffer presentation, verifies an initial write, and retains a verified SDL/framebuffer fallback.
- Pygame runtime bootstrap uses bundled CPython 3.11/aarch64 archives first, with safe extraction and ABI checks; the network fallback uses verified TLS.

## Superseded and deferred work

- PR #66, #86 and #88 were closed as superseded by the selective, tested integrations in #100–#102. The old fixed input mapping from #66 was intentionally not copied because current main already has firmware-aware Andromeda/non-Andromeda profiles.
- PR #89 (shared operation-feedback policy) remains separate and is not part of the current release candidate.
- LÖVE PRs #73, #87, #90, #91 and #92 remain experimental work. Their historical checks are not evidence of feature parity or hardware qualification; PR #92 must not be merged while GitHub reports it unmergeable.
- No feature from the LÖVE stack is promoted to the default handheld path by this consolidation.

## Known release blockers and boundaries

### Hardware / user-reported issues

- [Issue #1](https://github.com/SilverCrow2323/Void-Desk-Project/issues/1): browser launch reports an I/O error on muOS. Reproduction details and the full log are still insufficient to call this fixed.
- [Issue #2](https://github.com/SilverCrow2323/Void-Desk-Project/issues/2): RG35XXSP power-off can leave the device running after the LED extinguishes; the issue also reports NEXUS stutter.
- [Issue #42](https://github.com/SilverCrow2323/Void-Desk-Project/issues/42): RG35XXSP Bluetooth responsiveness needs the exact physical test matrix in the issue.
- Direct framebuffer startup, SDL fallback, 14-node navigation, external hand-off and Tree of Life frame-time/readability still require physical H700 testing. A QEMU test is not a framebuffer test on the handheld.

### BaseStation / SPDW Hub boundary

[Issue #78](https://github.com/SilverCrow2323/Void-Desk-Project/issues/78) explicitly keeps BaseStation at PC-only prototype/companion status until its secure pairing gates are complete. Still missing or unverified:

- installable handheld VOID_Uplink client and explicit user-confirmed pairing flow;
- random pairing secret generation, atomic owner-only persistence and non-empty fail-closed authentication;
- authenticated LAN round trip, token rotation/revocation and per-client capability lifecycle;
- origin policy, request validation, rate limiting and append-only audit coverage;
- installable assets/basestation/console_app target;
- known-host SSH/SFTP verification across the full pairing flow.

Do not claim secure pairing, central authentication, SPDW Hub or remote control as completed. BaseStation is not a release feature in this candidate.

## Required release gates

### G0 — Integration hygiene

- [x] Selectively integrate the Pygame NEXUS, framebuffer and bootstrap work on current main.
- [x] Preserve the firmware-aware Andromeda/non-Andromeda input mapping.
- [x] Close the superseded Pygame stack branches #66, #86 and #88 with explicit replacement references.
- [x] Explicitly defer PR #89 to a later scope; it is not part of the v10.5.4 candidate.

### G1 — Source and automated tests

- [x] PR #102 exact-head CI: 305 Python tests passed, 3 subtests passed; integrity audit, Pygame captures and shell checks passed.
- [x] PR #102 exact-head LÖVE/Rt:Tailscale-M integration and QEMU job passed.
- [x] PR #102 exact-head .muxapp and .deb package builds passed, with checksums.
- [x] Mainline CI #990 completed successfully on merge commit 715e349.
- [ ] Review the generated Pygame and LÖVE captures; automated capture is not manual visual approval.

### G2 — Packaging

- [x] Build .muxapp and Debian .deb from the same PR #102 candidate commit.
- [x] Verify Debian package metadata.
- [x] Upload handheld/PC artifacts and checksums in CI.
- [ ] Rebuild from final main after all documentation and release-scope changes.
- [ ] Verify install, upgrade and rollback on the target device.

### G3 — Desktop and visual QA

- [x] Automated Pygame home-style captures.
- [x] Automated LÖVE scene captures for its experimental scope.
- [ ] Manually inspect screenshots for clipping, focus, labels, contrast and Tree of Life overlap.
- [ ] Review 14-node route coverage and external app hand-off on a desktop muOS-compatible test environment.

### G4 — muOS / H700 physical qualification

- [ ] Record exact handheld model, muOS build, controller GUID and package SHA-256.
- [ ] Cold install, first launch, relaunch, update and rollback.
- [ ] Confirm direct framebuffer path or verified SDL fallback; check for black screen and write errors.
- [ ] Navigate all 14 NEXUS destinations with D-pad and confirm hidden/disabled QWASAR behaviour and protected recovery anchors.
- [ ] Check Tree of Life frame pacing and text/node readability for at least ten minutes.
- [ ] Test GAMES/PortMaster, DEVELOP, COMMUNITY and OUTERDESK hand-off; verify return to muOS and no stale Pygame environment leakage.
- [ ] Verify audio, storage, clean exit, reboot and power-off.
- [ ] Run the RG35XXSP Bluetooth/shutdown matrix separately before claiming those devices are fixed.
- [ ] Record logs and outcomes; use the H700 smoke-test checklist.

### G5 — Release publication

- [ ] Update final changelog with only verified user-visible changes.
- [ ] Align application and package version metadata.
- [ ] Publish install, upgrade, rollback and compatibility instructions.
- [ ] Attach the physically tested .muxapp and .deb artifacts with SHA-256 checksums.
- [ ] Create annotated tag and GitHub Release only after G0–G4 pass.

## Current decision

**NO-GO for public v10.5.4 release.**

The Pygame candidate has been integrated and both exact-head PR CI (#989) and post-merge mainline CI (#990) are green. The remaining blockers are not code-merge blockers: generated captures need manual review, the H700 framebuffer/NEXUS/external-app path needs physical testing, RG35XXSP issues #1/#2/#42 remain open, and BaseStation is explicitly outside the release scope until issue #78 is satisfied.

The next safe sequence is: manually inspect the artifacts, run the physical H700 smoke test with rollback available, resolve or explicitly scope the open device issues, then build the final release candidate. **Do not create a v10.5.4 tag before those gates close.**
