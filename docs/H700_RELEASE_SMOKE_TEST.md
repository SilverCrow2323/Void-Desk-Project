# H700 physical release smoke test — v10.5.4-NEXUS candidate

> This checklist is for a candidate build, not a public release. Keep the previous working package available and do not remove the native muOS recovery path.

## Before testing

Record:

- handheld model and hardware revision;
- exact muOS release/build (the current packaging target is muOS 2606.0 Andromeda);
- controller GUID and any custom input profile;
- candidate package filename and SHA-256;
- previous installed version and rollback package;
- test date and tester.

Use the .muxapp built from the final candidate commit. Do not install a source ZIP.

## 1. Install and launch

1. Back up the existing Void-Desk/ application directory or keep the previous .muxapp ready for reinstall.
2. Install through muOS Archive Manager.
3. Cold boot and launch Void Desk from Applications.
4. Confirm that the UI appears without a black screen.
5. Inspect the startup log for either “direct framebuffer active” or “SDL fallback framebuffer active”. Record which path was used.
6. If both paths fail or the log reports a framebuffer write error, stop and roll back.

## 2. Display and stability

1. Leave NEXUS open for at least ten minutes.
2. Confirm the screen updates on every orbit movement and no stale/black frame remains.
3. Check text, node labels, Tree of Life branches and panels for clipping or overlap.
4. Navigate repeatedly while the Tree of Life is animating; note pauses, tearing or input latency.
5. Repeat after closing and relaunching Void Desk.

Do not infer an FPS guarantee from desktop captures or QEMU.

## 3. NEXUS destinations and QWASAR profiles

Verify all 14 destinations:

- START SESSION
- MUOS APPS
- MEDIA VAULT
- THE FORGE
- RT:TOOLBOX
- UPLINK
- WORKSHOP
- SETTINGS
- INFO
- END NODE
- GAMES
- DEVELOP
- COMMUNITY
- OUTERDESK

Then test a profile that reorders, hides and disables mapped QWASAR workspaces:

- hidden nodes disappear from the orbit and cannot be selected;
- disabled nodes remain visible but are skipped by navigation and activation;
- START SESSION and END NODE remain visible and enabled;
- the six legacy destinations retain their stable IDs and identity;
- returning to the default profile restores the expected layout.

## 4. Controller and hub routes

1. Navigate with the D-pad; test confirm/back and the shoulder/ring controls used by the selected profile.
2. Confirm the Andromeda mapping matches the recorded firmware/controller GUID.
3. Open and leave each of the four extended hubs: GAMES, DEVELOP, COMMUNITY and OUTERDESK.
4. Test the Python REPL, file-manager hand-off, browser availability and shared-folder route where installed.
5. Test each installed OUTERDESK tool from the external registry:
   - VoidCast;
   - BGM Normalizer;
   - File-GD X (only if its LÖVE runtime is installed).
6. Confirm Void Desk hands off the display, the external process starts, and returning from the external app does not leave a stale Void Desk framebuffer or controller process.

## 5. PortMaster and system lifecycle

1. If PortMaster is installed, launch it from GAMES and confirm the hand-off works.
2. Return to muOS and launch Void Desk again.
3. Test reboot and power-off from the supported menu.
4. Confirm the device actually powers down; an extinguished LED alone is not sufficient.
5. Confirm a subsequent cold boot works normally.

## 6. Bluetooth and device-specific checks

For RG35XXSP claims, follow [issue #42](https://github.com/SilverCrow2323/Void-Desk-Project/issues/42) and [issue #2](https://github.com/SilverCrow2323/Void-Desk-Project/issues/2) separately. An H700 test does not close an RG35XXSP issue.

## 7. Rollback

If display, input, external hand-off, shutdown or boot fails:

1. stop further testing;
2. reinstall the previous known-good .muxapp or restore the backed-up Void-Desk/ directory;
3. cold boot and confirm muOS native Applications and recovery paths still work;
4. attach the log, device/firmware details and candidate SHA-256 to the relevant issue.

## Result record

| Check | Result | Notes / log reference |
|---|---|---|
| Install / first launch | Pending | |
| Direct framebuffer or SDL fallback | Pending | |
| 10-minute display stability | Pending | |
| All 14 NEXUS destinations | Pending | |
| QWASAR hide/disable/reorder | Pending | |
| Controller mapping | Pending | |
| External tools / hand-off | Pending | |
| PortMaster | Pending / N/A | |
| Reboot and power-off | Pending | |
| Rollback | Pending | |

A release claim requires a completed record tied to the exact package SHA-256, handheld model, muOS build and controller GUID.
