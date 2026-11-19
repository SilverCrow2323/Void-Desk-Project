"""Organic branch overlay for the NEXUS planetarium.

The orbital planetarium remains the navigation model; this layer adds a
readable parent/child topology without changing stable node IDs or routes.
"""
from __future__ import annotations

import math

# START SESSION is the root. Four primary branches lead to the main hubs;
# secondary branches group their related destinations.
TREE_EDGES = (
    (0, 3), (0, 5), (0, 2), (0, 6),
    (3, 4), (3, 11),
    (5, 12), (5, 13),
    (2, 10),
    (6, 1), (6, 7), (6, 8),
    (0, 9),
)


def branch_points(start, end, edge_index=0, segments=12):
    """Return deterministic integer points along an organic cubic branch."""
    if segments < 2:
        raise ValueError("segments must be at least 2")
    x0, y0 = map(float, start)
    x3, y3 = map(float, end)
    dx, dy = x3 - x0, y3 - y0
    distance = math.hypot(dx, dy)
    if distance < 1e-6:
        point = (round(x0), round(y0))
        return tuple(point for _ in range(segments + 1))
    nx, ny = -dy / distance, dx / distance
    side = -1.0 if edge_index % 2 else 1.0
    bend = min(34.0, max(10.0, distance * 0.12)) * side
    x1, y1 = x0 + dx * 0.28 + nx * bend, y0 + dy * 0.28 + ny * bend
    x2, y2 = x0 + dx * 0.72 + nx * bend * 0.55, y0 + dy * 0.72 + ny * bend * 0.55
    points = []
    for step in range(segments + 1):
        t = step / float(segments)
        u = 1.0 - t
        x = u**3*x0 + 3*u*u*t*x1 + 3*u*t*t*x2 + t**3*x3
        y = u**3*y0 + 3*u*u*t*y1 + 3*u*t*t*y2 + t**3*y3
        points.append((round(x), round(y)))
    return tuple(points)


def draw_life_tree(surface, positions, node_colors, selected, now,
                   disabled_nodes=()):
    """Draw low-cost branching links below the planet nodes.

    No temporary full-screen surfaces, fonts or per-frame random values are
    created. This is intentionally cheap for the H700's 640x480 framebuffer.
    """
    import pygame

    disabled = set(disabled_nodes)
    for edge_index, (parent, child) in enumerate(TREE_EDGES):
        start, end = positions.get(parent), positions.get(child)
        if start is None or end is None:
            continue
        points = branch_points(start, end, edge_index)
        color = node_colors.get(parent, (110, 150, 180))
        if parent in disabled or child in disabled:
            color = tuple(max(24, int(channel * 0.30)) for channel in color)
        active = selected in (parent, child) and child not in disabled
        # Deep bark-like underlay plus a thin coloured vein.
        pygame.draw.lines(surface, (8, 13, 22), False, points, 5)
        vein = tuple(max(18, int(channel * 0.34)) for channel in color)
        pygame.draw.lines(surface, vein, False, points, 2 if active else 1)
        # Small living junctions make the topology read as a branching tree.
        for joint_index in (4, 8):
            joint = points[joint_index]
            pygame.draw.circle(surface, vein, joint, 2 if active else 1)
        if active:
            pygame.draw.lines(surface, color, False, points, 2)
            pulse_index = int((now * 7.0 + edge_index * 1.7) % 11) + 1
            pygame.draw.circle(surface, color, points[pulse_index], 3)
