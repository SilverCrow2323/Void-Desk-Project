# Project: Void Desk

## Purpose
Provide a modular desktop-like environment for muOS handhelds, with a Python/Pygame reference frontend and a LÖVE frontend, local service bridge, optional Linux desktop session and app/tool integrations.

## Users and use cases
- RG35XX H/H700 muOS owners launching a lightweight desktop/session from the handheld.
- Maintainers integrating services such as Media Vault, UPLINK, Forge, diagnostics and MUOS Apps.
- Desktop developers testing the same logical journeys before physical-device qualification.

## Scope and boundaries
In scope: NEXUS navigation, frontend parity, service bridge, controller/input mapping, optional XFCE/IceWM session, APT tooling inside the optional desktop image, media/radio and app discovery, settings, diagnostics and muOS .muxapp/.deb packaging.

Out of scope: replacing muOS, writing bootloader/partition data, executing arbitrary untrusted shell strings, treating a UI callback as proof of a completed service operation, and claiming hardware support from screenshots alone. The optional Debian/Ubuntu image is isolated from the muOS host.

## Target
- Primary handheld: Anbernic RG35XX H / Allwinner H700, 640×480, muOS Andromeda 2606.0.
- Frontends: Python/Pygame reference and LÖVE 11.5.
- Packaging: muOS MUX app and Debian package for the optional desktop environment.

## Architecture
- Frontends: Pygame reference, LÖVE alternate; logical routes and action semantics must remain aligned.
- Service bridge: typed, bounded handlers with explicit errors and operation results.
- Desktop/session: isolated Linux image, display/session lifecycle and package jobs.
- Integrations: media, network, diagnostics, tools and installed muOS apps.
- Packaging: self-contained app folder, launcher, runtime libraries and Debian payload.

## Dependencies and integrations
muOS MUX launcher, Python, Pygame, LÖVE 11.5, SDL2, optional Debian/Ubuntu image, XFCE/IceWM, APT and MPV. Runtime binaries must be pinned and verified. Other SPDW apps are integrations, not implicit dependencies.

## Safety, accessibility and localization
No boot writes, formatting or recursive host deletion. Validate every target path, reject symlink escapes, bound service inputs and require confirmation for privileged/destructive operations. Never report success before the service confirms it. UI must be readable at 640×480 and fully controller-operable. User-facing UI remains English.

## Verified baseline
The repository contains both frontends, service bridge, package definitions and extensive host/static/scene tests. The LÖVE gap register remains the release roadmap: five NEXUS destinations are hidden, and physical RG35XX H validation is still required. CI screenshots and desktop keyboard tests are not hardware certification.
