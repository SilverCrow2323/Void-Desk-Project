import ast
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "assets" / "basestation"))

from daemon_security import authorize_client, valid_client_registry, valid_token  # noqa: E402


TOKEN = "A" * 43


class BaseStationSecurityTests(unittest.TestCase):
    def test_blank_and_short_tokens_are_rejected(self):
        self.assertFalse(valid_token(""))
        self.assertFalse(valid_token("short"))
        self.assertFalse(valid_client_registry({"uplink": {"token": "", "capabilities": ["status.read"]}}))

    def test_registry_requires_unique_tokens_and_known_capabilities(self):
        self.assertTrue(valid_client_registry({"uplink": {"token": TOKEN, "capabilities": ["status.read"]}}))
        self.assertFalse(valid_client_registry({
            "one": {"token": TOKEN, "capabilities": ["status.read"]},
            "two": {"token": TOKEN, "capabilities": ["outbox.read"]},
        }))
        self.assertFalse(valid_client_registry({"uplink": {"token": TOKEN, "capabilities": ["admin"]}}))

    def test_each_route_requires_its_declared_capability(self):
        clients = {"uplink": {"token": TOKEN, "capabilities": ["status.read", "inbox.write"]}}
        self.assertEqual(authorize_client(clients, TOKEN, "GET", "/ping"), ("uplink", True, "authorized"))
        self.assertEqual(authorize_client(clients, TOKEN, "POST", "/notify"), ("uplink", True, "authorized"))
        self.assertEqual(authorize_client(clients, TOKEN, "GET", "/outbox"), ("uplink", False, "capability_denied"))
        self.assertEqual(authorize_client(clients, TOKEN, "POST", "/outbox"), ("uplink", False, "capability_denied"))

    def test_unknown_route_and_wrong_token_fail_closed(self):
        clients = {"uplink": {"token": TOKEN, "capabilities": ["status.read"]}}
        self.assertEqual(authorize_client(clients, "B" * 43, "GET", "/ping"), (None, False, "auth_denied"))
        self.assertEqual(authorize_client(clients, "é" * 43, "GET", "/ping"), (None, False, "auth_denied"))
        self.assertEqual(authorize_client(clients, TOKEN, "DELETE", "/ping"), (None, False, "route_denied"))
        self.assertEqual(authorize_client({}, TOKEN, "GET", "/ping"), (None, False, "auth_denied"))

    def test_daemon_source_is_loopback_only_and_has_no_wildcard_cors(self):
        source = (REPO_ROOT / "assets" / "basestation" / "basestation.py").read_text(encoding="utf-8")
        self.assertIn('ThreadingHTTPServer(("127.0.0.1", self.port), handler)', source)
        self.assertNotIn('Access-Control-Allow-Origin", "*"', source)
        self.assertIn('valid_client_registry(self.store.cfg.get("clients", {}))', source)

    def test_new_device_profiles_do_not_seed_shared_passwords(self):
        source = (REPO_ROOT / "assets" / "basestation" / "basestation.py").read_text(encoding="utf-8")
        tree = ast.parse(source)
        assignment = next(
            node for node in tree.body
            if isinstance(node, ast.Assign)
            and any(isinstance(target, ast.Name) and target.id == "DEFAULT_SERVICES"
                    for target in node.targets)
        )
        services = ast.literal_eval(assignment.value)
        for service_id, service in services.items():
            if service.get("auth"):
                with self.subTest(service=service_id):
                    self.assertEqual(service.get("user"), "")
                    self.assertEqual(service.get("pass"), "")

    def test_ssh_and_sftp_reject_unknown_host_keys(self):
        source = (REPO_ROOT / "assets" / "basestation" / "basestation.py").read_text(encoding="utf-8")
        ssh = source.split("class SSHManager:", 1)[1].split("# §6", 1)[0]
        self.assertIn("client.load_system_host_keys()", ssh)
        self.assertIn("paramiko.RejectPolicy()", ssh)
        self.assertNotIn("paramiko.AutoAddPolicy()", ssh)
        self.assertNotIn("paramiko.Transport(", ssh)
        self.assertIn("client.open_sftp()", ssh)
        self.assertGreaterEqual(ssh.count("SSHManager._new_client()"), 2)

    def test_documentation_keeps_the_remaining_uplink_boundary_explicit(self):
        readme = (REPO_ROOT / "assets" / "basestation" / "README.md").read_text(encoding="utf-8")
        ecosystem = (REPO_ROOT / "docs" / "PRODUCT_ECOSYSTEM_MAP.md").read_text(encoding="utf-8")
        self.assertIn("known-hosts database", readme)
        self.assertIn("leave usernames and passwords blank", readme)
        self.assertIn("PC-only prototype", ecosystem)
        self.assertIn("installable handheld Uplink client", ecosystem)
        self.assertIn("Do not expose the embedded daemon as a production service", ecosystem)


if __name__ == "__main__":
    unittest.main()
