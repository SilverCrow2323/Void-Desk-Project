# UPLINK — Network Control Hub

UPLINK has its own cyan/ice-blue identity and a layout separate from THE FORGE.
The main view is a network operations dashboard rather than a carousel.

## Main layout
- Three top status cards: Wi-Fi, Hotspot and Bluetooth. Each shows live state and the
  connected SSID, hotspot SSID or local Bluetooth adapter name.
- Four service cards: B.S. Server, Tailscale, Syncthing and FTPiercer.
- Lower maintenance list: Network Probe, Wi-Fi Scanner and Refresh Connections.
- Animated network-mesh background; detail screens use Wi-Fi, AP ripple, Bluetooth
  topology, server-rack, transfer-stream and radar motifs.

## Working controls
- Wi-Fi: read state, scan nearby networks, and enable/disable the radio through
  rfkill when available. Network joining remains managed by muOS; this screen does
  not store Wi-Fi credentials.
- Hotspot: start/stop through existing guarded scripts; the screen warns that
  single-radio hardware may interrupt the upstream Wi-Fi link.
- Bluetooth: read adapter name/power and paired count, scan, power on/off, pair,
  trust, connect and disconnect using a strict MAC-address allowlist.
- Tailscale and Syncthing open their existing native LÖVE management scenes.
- Network Probe uses fixed targets for ICMP to 1.1.1.1 and DNS lookup of example.com,
  with bounded timeouts and no caller-supplied commands.

## Explicit integration boundaries
- **B.S. Server / VOID BaseStation** is documented as PC-only. The handheld card is
  informational and does not start its prototype daemon or expose a server endpoint.
- **FTPiercer** is referenced by legacy Python navigation, but no FTP profile/transfer
  service bridge is registered in the LÖVE frontend. Its panel is a migration
  placeholder, not a non-functional connect button.

## Runtime validation
Focused tests and visual-capture fixtures cover the new contracts. They do not
constitute physical H700 verification. Radio actions depend on the presence and
behaviour of rfkill / bluetoothctl on the target muOS build.
