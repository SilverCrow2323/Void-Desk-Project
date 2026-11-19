import importlib.util
from pathlib import Path
from types import SimpleNamespace


ROOT = Path(__file__).resolve().parents[1]


def load_service():
    script = ROOT / "service" / "voiddesk_service.py"
    spec = importlib.util.spec_from_file_location("voiddesk_uplink_service_test", script)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_network_status_visual_fixture_includes_radio_names_and_switches(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", True)
    result = service.h_network_status({})
    assert result["ok"] is True
    network = result["network"]
    assert network["wifi"]["ssid"] == "VOIDDESK-LAB"
    assert network["wifi"]["radio_on"] is True
    assert network["hotspot"]["on"] is False
    assert network["bt"]["name"] == "VOIDDESK-H700"
    assert network["bt"]["available"] is True
    assert network["bt"]["on"] is True


def test_wifi_radio_cannot_be_disabled_while_hotspot_is_active(tmp_path, monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(service, "DATA", tmp_path)
    (tmp_path / ".hotspot_active").write_text("VoidDesk-AP", encoding="utf-8")
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/sbin/rfkill")

    def fail_run(*_args, **_kwargs):
        raise AssertionError("rfkill must not run while the AP is active")

    monkeypatch.setattr(service.subprocess, "run", fail_run)
    result = service.h_wifi_action({"action": "radio_off"})
    assert result["ok"] is False
    assert "stop the hotspot" in result["error"]


def test_wifi_radio_actions_are_allowlisted_and_call_rfkill(tmp_path, monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(service, "DATA", tmp_path)
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/sbin/rfkill")
    calls = []

    def fake_run(command, **_kwargs):
        calls.append(command)
        return SimpleNamespace(returncode=0, stdout="", stderr="")

    monkeypatch.setattr(service.subprocess, "run", fake_run)
    result = service.h_wifi_action({"action": "radio_on"})
    assert result == {"ok": True, "state": "on"}
    assert calls == [["rfkill", "unblock", "wifi"]]

    rejected = service.h_wifi_action({"action": "run arbitrary command"})
    assert rejected["ok"] is False
    assert len(calls) == 1


def test_bluetooth_device_actions_require_a_valid_mac_and_use_fixed_argv(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/bin/bluetoothctl")
    calls = []

    def fake_run(command, **_kwargs):
        calls.append(command)
        return SimpleNamespace(returncode=0, stdout="Pairing successful", stderr="")

    monkeypatch.setattr(service.subprocess, "run", fake_run)
    invalid = service.h_bt_action({"action": "pair", "mac": "not-a-device"})
    assert invalid["ok"] is False
    assert calls == []

    result = service.h_bt_action({
        "action": "pair", "mac": "00:11:22:33:44:55",
    })
    assert result["ok"] is True
    assert calls == [["bluetoothctl", "pair", "00:11:22:33:44:55"]]


def test_bluetooth_snapshot_reads_alias_power_and_paired_count(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/bin/bluetoothctl")

    def fake_run(command, **_kwargs):
        if command[-1] == "show":
            return SimpleNamespace(
                returncode=0, stdout="Controller AA:BB:CC:DD:EE:FF\n    Alias: H700-Blue\n    Powered: yes\n",
                stderr="",
            )
        if command[-1] == "paired-devices":
            return SimpleNamespace(
                returncode=0,
                stdout="Device 00:11:22:33:44:55 Headphones\nDevice 10:20:30:40:50:60 Pad\n",
                stderr="",
            )
        raise AssertionError(command)

    monkeypatch.setattr(service.subprocess, "run", fake_run)
    result = service._bluetooth_snapshot(False)
    assert result == {
        "available": True, "name": "H700-Blue", "on": True, "count": 2,
    }


def test_network_probe_visual_fixture_is_deterministic(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", True)

    def fail_run(*_args, **_kwargs):
        raise AssertionError("visual capture must not probe the real network")

    monkeypatch.setattr(service.subprocess, "run", fail_run)
    result = service.h_network_probe({})
    assert result["ok"] is True
    assert result["probe"]["gateway"] == "192.168.1.1"
    assert result["probe"]["interface"] == "wlan0"
    assert result["probe"]["internet"] is True


def test_uplink_network_action_handlers_are_registered():
    service = load_service()
    assert service.HANDLERS["network_probe"] is service.h_network_probe
    assert service.HANDLERS["wifi_action"] is service.h_wifi_action
    assert service.HANDLERS["bt_action"] is service.h_bt_action


def test_visual_capture_scanners_return_usable_fixture_rows(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", True)
    monkeypatch.setattr(service, "IS_DEVICE", False)

    wifi = service.h_wifi_scan({})
    bt = service.h_bt_scan({})
    assert wifi["networks"][0]["ssid"] == "VOIDDESK-LAB"
    assert len(wifi["networks"]) == 3
    assert bt["devices"][0]["mac"] == "00:11:22:33:44:55"
    assert len(bt["devices"]) == 2


def test_bluetooth_snapshot_reports_unavailable_without_a_controller(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/bin/bluetoothctl")
    monkeypatch.setattr(
        service.subprocess, "run",
        lambda *_args, **_kwargs: SimpleNamespace(
            returncode=0, stdout="No default controller available", stderr="",
        ),
    )
    assert service._bluetooth_snapshot(True) == {
        "available": False, "name": "—", "on": False, "count": 0,
    }


def test_wifi_saved_profiles_hide_credentials_and_parse_spaces_in_ssid(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(
        service, "deskinfo", SimpleNamespace(wireless_ifaces=lambda: ["lo"]),
    )
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/sbin/wpa_cli")
    calls = []

    def fake_run(command, **_kwargs):
        calls.append(command)
        return SimpleNamespace(
            returncode=0,
            stdout=(
                "network id / ssid / bssid / flags\n"
                "0\tHome Network\tany\t[CURRENT]\n"
                "1\tGuest\tany\t[DISABLED]\n"
            ),
            stderr="",
        )

    monkeypatch.setattr(service.subprocess, "run", fake_run)
    result = service.h_wifi_saved({})
    assert result["ok"] is True
    assert result["profiles"] == [
        {"id": "0", "ssid": "Home Network", "current": True, "disabled": False},
        {"id": "1", "ssid": "Guest", "current": False, "disabled": True},
    ]
    assert calls == [["wpa_cli", "-i", "lo", "list_networks"]]
    assert "psk" not in repr(result).lower()


def test_wifi_profile_action_selects_only_an_existing_numeric_profile(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(
        service, "deskinfo", SimpleNamespace(wireless_ifaces=lambda: ["lo"]),
    )
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/sbin/wpa_cli")
    calls = []

    def fake_run(command, **_kwargs):
        calls.append(command)
        if command[-1] == "list_networks":
            return SimpleNamespace(
                returncode=0,
                stdout="network id / ssid / bssid / flags\n2\tOffice Wi-Fi\tany\t\n",
                stderr="",
            )
        return SimpleNamespace(returncode=0, stdout="OK", stderr="")

    monkeypatch.setattr(service.subprocess, "run", fake_run)
    bad = service.h_wifi_profile_action({"action": "select", "id": "999"})
    assert bad["ok"] is False
    assert "no longer exists" in bad["error"]
    assert len(calls) == 1

    result = service.h_wifi_profile_action({"action": "select", "id": "2"})
    assert result == {"ok": True, "state": "connecting", "ssid": "Office Wi-Fi"}
    assert calls[-2:] == [
        ["wpa_cli", "-i", "lo", "select_network", "2"],
        ["wpa_cli", "-i", "lo", "reassociate"],
    ]


def test_wifi_forget_requires_explicit_confirmation_and_saves_profile(monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(
        service, "deskinfo", SimpleNamespace(wireless_ifaces=lambda: ["lo"]),
    )
    monkeypatch.setattr(service.shutil, "which", lambda name: "/usr/sbin/wpa_cli")
    calls = []

    def fake_run(command, **_kwargs):
        calls.append(command)
        if command[-1] == "list_networks":
            return SimpleNamespace(
                returncode=0,
                stdout="network id / ssid / bssid / flags\n3\tOld Network\tany\t\n",
                stderr="",
            )
        return SimpleNamespace(returncode=0, stdout="OK", stderr="")

    monkeypatch.setattr(service.subprocess, "run", fake_run)
    confirm = service.h_wifi_profile_action({"action": "forget", "id": "3"})
    assert confirm["confirm_required"] is True
    assert len(calls) == 1

    result = service.h_wifi_profile_action({
        "action": "forget", "id": "3", "confirm": True,
    })
    assert result == {"ok": True, "state": "forgotten", "saved": True}
    assert calls[-2:] == [
        ["wpa_cli", "-i", "lo", "remove_network", "3"],
        ["wpa_cli", "-i", "lo", "save_config"],
    ]


def test_hotspot_start_requires_confirmation_when_single_radio_may_drop_wifi(
        tmp_path, monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(service, "DATA", tmp_path)
    monkeypatch.setattr(service, "APP_DIR", tmp_path / "VoidDesk")
    monkeypatch.setattr(
        service, "deskinfo",
        SimpleNamespace(wifi_status=lambda: (True, "Home", 3, "wlan0", "192.168.1.2")),
    )
    monkeypatch.setenv("VD_WLAN1_SYSFS", str(tmp_path / "no-secondary-radio"))

    def fail_run(*_args, **_kwargs):
        raise AssertionError("hotspot must not start before explicit confirmation")

    monkeypatch.setattr(service.subprocess, "run", fail_run)
    result = service.h_hotspot_toggle({})
    assert result["ok"] is False
    assert result["confirm_required"] is True


def test_hotspot_start_does_not_assume_no_wifi_when_interface_probe_is_missing(
        tmp_path, monkeypatch):
    service = load_service()
    monkeypatch.setattr(service, "IS_DEVICE", True)
    monkeypatch.setattr(service, "IS_VISUAL_CAPTURE", False)
    monkeypatch.setattr(service, "DATA", tmp_path)
    monkeypatch.setattr(service, "APP_DIR", tmp_path / "VoidDesk")
    monkeypatch.setattr(service, "deskinfo", None)
    monkeypatch.setenv("VD_WLAN1_SYSFS", str(tmp_path / "no-secondary-radio"))

    def fail_run(*_args, **_kwargs):
        raise AssertionError("unknown radio topology must require confirmation")

    monkeypatch.setattr(service.subprocess, "run", fail_run)
    result = service.h_hotspot_toggle({})
    assert result["confirm_required"] is True
