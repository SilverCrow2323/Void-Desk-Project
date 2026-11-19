# NEXUS — Tree of Life / Planetarium

## Intent

The NEXUS home screen keeps the original Kid Desk-inspired planetarium language:
moving orbital bodies, a central START SESSION star, depth, parallax and a
camera that follows the selected destination. The new Tree of Life layer adds
a second reading of the same map: destinations are also connected by organic
parent/child branches.

This is a visual and navigation-layer evolution, not a new route system.

## Visual hierarchy

- **Root:** START SESSION (node 0).
- **Primary branches:** THE FORGE (3), UPLINK (5), MEDIA VAULT (2), WORKSHOP (6).
- **Forge leaves:** Rt:TOOLBOX (4), DEVELOP (11).
- **Uplink leaves:** COMMUNITY (12), OUTERDESK (13).
- **Media leaf:** GAMES (10).
- **Workshop leaves:** muOS APPS (1), SETTINGS (7), INFO (8).
- **Terminal branch:** END NODE (9).

Orbital rings remain visible as the planetarium's spatial guide. Branches are
drawn behind planets, with restrained bark-dark underlays, muted coloured
veins, small junctions and a travelling highlight on the selected path.

## Interaction and compatibility

- Existing node IDs, profile ordering, visibility/disabled semantics and scene
  routes are unchanged.
- Existing D-pad and shoulder navigation remains authoritative.
- The selected node continues to drive the existing contextual report panel.
- The visual overlay uses the current 640×480 scene coordinates and creates no
  full-screen temporary surfaces or per-frame random geometry.
- Disabled destinations remain visible but their branches are muted; they
  cannot become active through this visual layer.

## Acceptance gates

1. Python unit tests validate deterministic branch geometry and topology.
2. Existing Pygame visual-capture workflow renders NEXUS and all other home
   styles without regression.
3. CI package build and checksum complete on the exact PR head.
4. Physical H700 review checks legibility, D-pad navigation, FPS stability and
   clean return to muOS. CI screenshots are not hardware certification.
