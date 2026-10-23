"""Contract tests for the stdio permission filter (without Graphify dependency)."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = [(lang, system) for lang in ("TR", "EN") for system in ("Windows", "Linux", "macOS")]
BACKEND = """
import json
import sys
for raw in sys.stdin:
    msg = json.loads(raw)
    method = msg.get("method")
    if method == "tools/list":
        names = ["query_graph","get_node","get_neighbors","shortest_path","graph_stats",
                 "get_community","god_nodes","list_prs","get_pr_impact","triage_prs"]
        result = {"tools":[{"name":name} for name in names]}
    elif method == "tools/call":
        result = {"content":[{"type":"text","text":msg["params"]["name"]}]}
    else:
        result = {}
    print(json.dumps({"jsonrpc":"2.0","id":msg.get("id"),"result":result}), flush=True)
"""


class ProfileProxyTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        (self.root / "graphify-out").mkdir()
        self.backend = self.root / "graphify-out" / "graph.json"
        self.backend.write_text(BACKEND, encoding="utf-8")

    def tearDown(self):
        self.temp.cleanup()

    def query(self, script, profile, requests):
        command = [sys.executable, str(script), sys.executable, str(self.backend), profile, str(self.root)]
        payload = "".join(json.dumps(request) + "\n" for request in requests)
        completed = subprocess.run(command, input=payload, text=True, capture_output=True, timeout=15)
        self.assertEqual(completed.returncode, 0, completed.stderr)
        return {item["id"]: item for item in map(json.loads, completed.stdout.splitlines())}

    def test_profiles_and_project_isolation(self):
        for lang, system in PACKAGES:
            with self.subTest(package=f"{lang}/{system}"):
                script = ROOT / lang / system / "graphify-mcp-proxy.py"
                self.assertTrue(script.is_file())
                self.assertEqual(subprocess.run([sys.executable, "-m", "py_compile", str(script)], capture_output=True).returncode, 0)
                for profile, count in (("Minimal", 5), ("Balanced", 7), ("Full", 10)):
                    with self.subTest(profile=profile):
                        responses = self.query(script, profile, [
                            {"jsonrpc":"2.0","id":1,"method":"tools/list"},
                            {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"query_graph","arguments":{}}},
                            {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"triage_prs","arguments":{}}},
                            {"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"query_graph","arguments":{"project_path":str(self.root.parent)}}},
                        ])
                        self.assertEqual(len(responses[1]["result"]["tools"]), count)
                        self.assertIn("result", responses[2])
                        self.assertEqual("error" in responses[3], profile != "Full")
                        self.assertIn("error", responses[4])

    def test_invalid_profile_rejected(self):
        script = ROOT / "EN/Linux/graphify-mcp-proxy.py"
        command = [sys.executable, str(script), sys.executable, str(self.backend), "SuperUser", str(self.root)]
        result = subprocess.run(command, input="", text=True, capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 2)


if __name__ == "__main__":
    unittest.main()
