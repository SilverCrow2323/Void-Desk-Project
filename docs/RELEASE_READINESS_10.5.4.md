# Void Desk 10.5.4 — release consolidation gate

> Status snapshot: 22 November 2026, updated after PR #84 integration. This is an engineering gate, not a release announcement.
>
> The latest published handheld package remains v10.2.0. The v10.5.4-NEXUS line is still a candidate. v12 remains a blueprint, not an installable release.

## Release policy

- Keep `main` protected from speculative integration. Consolidate on `release/consolidation-2026-11` and merge through reviewed pull requests.
- Preserve the current Pygame reference frontend. LÖVE remains experimental until its declared release scope passes the same user-journey and hardware gates.
- A green source CI is necessary but does not certify muOS/H700 hardware.
- Do not publish a release tag or binary until the packaging, installation, rollback and physical-device gates below are evidenced.
- Do not advertise BaseStation as a completed SPDW Hub or secure paired remote-control product.

## Baseline verified on 22 November 2026

| Area | Evidence | Release interpretation |
|---|---|---|
| Main CI | CI run 955 on `dd179668` completed successfully on 22 Nov | Mainline source checks are green |
| Documentation/UI maintenance | PR #84 merged as `a4561ce`; rerun CI 44388775150 completed with all 3 jobs successful | Portal links and BaseStation backdrop dismissal are now on `main`; no Pages deployment is implied |
| Launcher | PR #94 merged; Pygame is the validated default engine | Keep Pygame as the reference path |
| SSH host-key policy | PR #95 merged; main CI run 955 passed | Known-host verification is present on the audited SSH surfaces |
| BaseStation containment | PR #79 merged; loopback-only listener, fail-closed auth and route capabilities | Containment only; not full pairing/product integration |
| BaseStation SSH follow-up | PR #95 merged; AndroidStation rejects unknown host keys | Pairing UI and known-host provisioning remain incomplete |
| Latest public package | v10.2.0, published 11 Aug 2026 | No 10.5.4 release artifact exists yet |

## Open integration stack

The following work is not an independent set of merge-ready PRs. Respect the stacked bases and rebase/retest each layer against current `main`.

### Pygame / NEXUS stack

1. PR #66 — QWASAR profile state in Pygame NEXUS (draft; base `main`).
2. PR #86 — Tree of Life planetarium (stacked on #66).
3. PR #88 — NEXUS renderer fail-safe (stacked on #86).
4. PR #89 — shared operation-feedback policy (stacked on #88).
5. PR #90 — Start Session hub (stacked on #89).
6. PR #91 — THE FORGE (stacked on #90; its recorded checks passed on 19 Nov).
7. PR #92 — UPLINK (stacked on #91; its recorded checks passed on 19 Nov, but GitHub currently reports the PR as not mergeable).

### LÖVE stack

1. PR #73 — LÖVE frontend overhaul (draft; recorded checks passed on 15 Nov).
2. PR #87 — Tree of Life parity (stacked on #73).

Do not merge a child PR before its parent is integrated and the child has been rebased and revalidated. Do not treat the historical green checks on #73, #91 or #92 as proof against the current mainline.

### Documentation branch

PR #84 was marked ready and squash-merged into `main` as `a4561ce2ddbb77a00e365c8e8fe1b0f1b1b1ee78`. The rerun workflow (run 44388775150) completed successfully: `.muxapp/.deb` build, Python checks, and Lua/LÖVE/Rt:Tailscale-M integration all passed. The original APT download timeout was transient. The merge does not certify a live Pages deployment or handheld hardware.

## Known release blockers

### Hardware and user-reported issues

- Issue #2: RG35XXSP shutdown and Bluetooth responsiveness. Source fixes exist, but physical confirmation is still required.
- Issue #42: RG35XXSP Bluetooth responsiveness. Verify the exact model/firmware/controller combination and capture repeatable evidence.
- Issue #1: browser launch I/O error. Reproduction details and the full error/log are still needed; do not mark it fixed without evidence.

### BaseStation / SPDW Hub boundary

Issue #78 remains open by design. Merged containment work is not the full integration. Still missing or unverified:

- installable handheld `VOID_Uplink` client;
- explicit pairing UI and user-confirmed secret delivery;
- authenticated LAN transport and end-to-end pairing round trip;
- token rotation/revocation and complete per-client capability lifecycle;
- rate limiting and full audit lifecycle;
- installable `assets/basestation/console_app` target.

Until those are implemented and tested, label BaseStation as a PC-only prototype/companion. Keep it out of the release's completed-feature claims.

## Required release gates

### G0 — Integration hygiene
- [ ] Rebase each active PR on current `main` in dependency order.
- [ ] Resolve conflicts explicitly; no force-push over unrelated work.
- [ ] Review changed files and security-sensitive operations.
- [ ] Re-run CI on each exact final PR head.

### G1 — Source and automated tests
- [ ] Python compile, lint and complete pytest suite.
- [ ] Lua/LÖVE syntax, scene and bridge contract tests.
- [ ] Shell syntax and launcher/lifecycle tests.
- [ ] Build validator and package layout tests.
- [ ] NEXUS route/action audit: every visible control routes to a real action or is visibly disabled with a reason.
- [ ] Regression tests for all fixes included in the candidate.

### G2 — Packaging
- [ ] Build `.muxapp` and Debian `.deb` from the same candidate commit.
- [ ] Verify exactly one top-level `Void-Desk/` package root.
- [ ] Verify required runtime/submodule assets and executable permissions.
- [ ] Verify no desktop virtualenv, secrets, test captures or developer-only files leak into the package.
- [ ] Record SHA-256 checksums and archive the build logs.

### G3 — Desktop and visual QA
- [ ] Pygame render-state capture and manual review.
- [ ] LÖVE scene capture and manual review for its declared experimental scope.
- [ ] Controller navigation, focus restoration, back paths, small-screen clipping and error/empty/offline states.
- [ ] Validate all hub routes: NEXUS, SESSION, THE FORGE, UPLINK, WORKSHOP, MUOS APPS, SETTINGS and END SESSION.

### G4 — muOS/H700 physical qualification
- [ ] Test exact muOS release + handheld model + controller GUID; do not infer compatibility from H700 alone.
- [ ] Cold install, first launch, relaunch, update and rollback.
- [ ] Test Pygame default path, controller input, audio, storage and clean return to muOS.
- [ ] Test shutdown/reboot and Bluetooth responsiveness on RG35XXSP where claimed.
- [ ] Exercise service-offline, permission-denied, timeout and cancellation paths.
- [ ] Record device, firmware, frontend, logs and outcome for every test.

### G5 — Release publication
- [ ] Update CHANGELOG with only verified user-visible changes.
- [ ] Align application and package version metadata.
- [ ] Publish install/upgrade/rollback instructions and compatibility matrix.
- [ ] Attach tested `.muxapp` and `.deb` artifacts with checksums.
- [ ] Create annotated tag and GitHub Release only after G0–G4 pass.

## Current decision

**NO-GO for public release.** The mainline CI and PR #84 rerun are green, but the feature stacks remain drafts and two major base branches are currently reported dirty against their parent (`#66`, `#73`). Hardware issues remain unverified, the full BaseStation pairing scope is explicitly incomplete, and no 10.5.4 package has been built from a single integrated candidate.

The next safe execution sequence is: rebase the Pygame stack in order, run exact-head CI, integrate and retest the LÖVE branch separately, keep the documentation/portal publishing state explicit, then build and physically qualify the candidate. No release tag should be created before these gates are closed.
