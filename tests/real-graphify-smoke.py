"""Live integration check: actual Graphify, stdio transport, and profile-filtered MCP."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

PROXY = Path(__file__).resolve().parents[1] / "EN" / "Linux" / "graphify-mcp-proxy.py"
BACKEND = shutil.which("graphify-mcp")
GRAPHIFY = shutil.which("graphify")
if not BACKEND or not GRAPHIFY:
    raise SystemExit("Real Graphify and graphify-mcp commands are required")

with tempfile.TemporaryDirectory(prefix="graphify-real-") as folder:
    project = Path(folder)
    (project / "sample.py").write_text(
        "def double(value: int) -> int:\n    return value * 2\n\n"
        "def quadruple(value: int) -> int:\n    return double(double(value))\n",
        encoding="utf-8",
    )
    extracted = subprocess.run(
        [GRAPHIFY, "extract", ".", "--code-only", "--no-cluster"],
        cwd=project, text=True, capture_output=True, timeout=120,
    )
    if extracted.returncode:
        raise RuntimeError("Graphify extraction failed: " + extracted.stderr[-4000:])
    graph = project / "graphify-out" / "graph.json"
    if not graph.is_file():
        raise RuntimeError("Real Graphify did not write graphify-out/graph.json")

    requests = [
        {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {
            "protocolVersion": "2025-06-18",
            "capabilities": {},
            "clientInfo": {"name": "bootstrap-ci", "version": "1.0"},
        }},
        {"jsonrpc": "2.0", "method": "notifications/initialized"},
        {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}},
        {"jsonrpc": "2.0", "id": 3, "method": "resources/read", "params": {"uri": "file:///no-access"}},
        {"jsonrpc": "2.0", "id": 4, "method": "tools/call",
         "params": {"name": "query_graph", "arguments": {"project_path": str(project.parent), "query": "double"}}},
    ]
    payload = "".join(json.dumps(item) + "\n" for item in requests)
    completed = subprocess.run(
        [sys.executable, str(PROXY), BACKEND, str(graph), "Minimal", str(project)],
        input=payload, text=True, capture_output=True, timeout=45,
    )
    if completed.returncode:
        raise RuntimeError("MCP proxy failed: " + completed.stderr[-4000:])
    replies = {}
    for line in completed.stdout.splitlines():
        data = json.loads(line)
        if "id" in data:
            replies[data["id"]] = data
    if "result" not in replies.get(1, {}):
        raise RuntimeError("Real MCP handshake missing: " + repr(replies) + "\n" + completed.stderr[-2000:])
    tools = replies.get(2, {}).get("result", {}).get("tools", [])
    names = {item["name"] for item in tools}
    expected = {"query_graph", "get_node", "get_neighbors", "shortest_path", "graph_stats"}
    if names != expected:
        raise RuntimeError(f"Unexpected live tool list: {names}; expected {expected}; stderr={completed.stderr[-2000:]}")
    for denied in (3, 4):
        if "error" not in replies.get(denied, {}):
            raise RuntimeError(f"Denied request {denied} reached Graphify: {replies.get(denied)}")
    print("Real Graphify MCP integration passed: handshake, tools, denied resources and cross-project access")
