# VOID BaseStation — PC-only prototype

BaseStation runs on the PC, not on the handheld. It currently provides local SSH/SFTP tooling and a small embedded telemetry daemon. It is **not yet the completed SPDW Hub or a paired VOID_Uplink product**.

## Install

```bash
sudo apt install python3-tk
python3 -m pip install paramiko
python3 basestation.py
```

## SSH host-key verification

BaseStation uses the PC's system SSH known-hosts database and rejects unknown host keys for both command execution and SFTP uploads. Before connecting to a handheld for the first time, obtain its host-key fingerprint through a trusted local channel, verify it, and add the verified key to `~/.ssh/known_hosts`. A changed or unknown key must fail closed; do not enable automatic host-key acceptance.

New service profiles leave usernames and passwords blank. Enter credentials that are valid for the specific device; the old shared `root/root` and `muos/muos` values are no longer seeded. Existing saved profiles are not silently rewritten, so review any older profile and replace default credentials manually.

## Embedded daemon security boundary

The daemon is intentionally fail-closed:

- It will not start unless `~/.config/void_basestation/daemon.json` contains at least one valid paired-client record.
- Each client token must be URL-safe and at least 32 characters. Generate a fresh value with `python3 -c 'import secrets; print(secrets.token_urlsafe(32))'`.
- Every route has a distinct capability: `status.read`, `outbox.read`, `inbox.write`, or `outbox.write`.
- The HTTP listener binds only to `127.0.0.1`; it does not expose an unauthenticated LAN service.
- Wildcard CORS is disabled. No browser origin is implicitly trusted.
- Authentication denials and successful state-changing requests are appended to `daemon-audit.jsonl` with owner-only file permissions. Tokens and request bodies are never written to that audit file.

Example local-development configuration (replace the placeholder with a freshly generated token):

```json
{
  "port": 31337,
  "pc_name": "VOID-PC",
  "clients": {
    "local-uplink": {
      "token": "REPLACE_WITH_A_RANDOM_URL_SAFE_TOKEN",
      "capabilities": ["status.read", "outbox.read"]
    }
  }
}
```

This is a local development contract only. The handheld pairing UI, installable VOID_Uplink client, authenticated LAN transport, token rotation/revocation flow, and full SPDW Hub audit/capability lifecycle are not yet implemented. Do not change the listener to `0.0.0.0` or expose this HTTP daemon through port forwarding.

The daemon's former blank-token bypass is deliberately not retained: old configurations containing only `token=` no longer enable it.
