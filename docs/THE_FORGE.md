# THE FORGE — circular software workshop

THE FORGE is the red-accented software workshop, visually separate from the gold START SESSION selector.

## Visual direction
- Near-black / charcoal surfaces with ember-red highlights.
- Animated sparks and particles behind the interface.
- Circular module carousel: six destinations orbit a central selected-module preview. D-pad rotates; A opens.
- The Forge palette is red; START SESSION retains its gold identity.

## Modules
- **Forge Installer** — curated package recommendations grouped into Essentials, Diagnostics and Media Tools.
- **APT Package Manager** — full package search and metadata.
- **Installed & Remove** — installed package inventory and existing remove flow.
- **System Maintenance** — APT index refresh, upgrade and cache clean.
- **Operations & Progress** — existing job list and logs.
- **Shell & CLI** — existing local service terminal.

## Safety and scope
All package actions use the existing apt_catalog / job_start service bridge and vd_apt_manage.py, targeting the optional Debian/Ubuntu XFCE image. The muOS/Buildroot host is not passed to APT. The curated installer has a fixed package list and does not accept arbitrary shell commands.

The curated list is a recommendation set, not a guarantee that every package exists in every configured repository. APT remains authoritative. No package installation, removal or upgrade has been executed as part of this source change. Runtime and H700 validation remain outstanding.