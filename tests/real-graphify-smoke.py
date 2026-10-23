"""Live integration check: actual Graphify, stdio transport, and profile-filtered MCP."""
import json
import queue
import threading
import time
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

    # MCP requires an initialize response BEFORE initialized notification and
    # tools/list; batching all messages races the backend on fast CI machines.
    proc = subprocess.Popen(
        [sys.executable, str(PROXY), BACKEND, str(graph), "Minimal", str(project)],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, bufsize=1,
    )
    channel = queue.Queue()

    def reader():
        for raw in proc.stdout:
            try:
                channel.put(json.loads(raw))
            except ValueError as exc:
                channel.put({"bad_json": str(exc), "raw": raw[:300]})
        channel.put(None)

    threading.Thread(target=reader, daemon=True).start()

    def send(method, *, request_id=None, params=None):
        request = {"jsonrpc": "2.0", "method": method}
        if request_id is not None:
            request["id"] = request_id
        if params is not None:
            request["params"] = params
        proc.stdin.write(json.dumps(request) + "\n")
        proc.stdin.flush()

    def response(request_id, timeout=20):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                item = channel.get(timeout=max(0.01, deadline - time.monotonic()))
            except queue.Empty:
                break
            if item is None:
                raise RuntimeError(f"MCP backend closed before request {request_id} completed")
            if not isinstance(item, dict) or "bad_json" in item:
                raise RuntimeError(f"Invalid MCP response: {item!r}")
            if "method" in item and item.get("method") != "notifications/tools/list_changed":
                raise RuntimeError(f"Unsolicited backend request bypassed proxy: {item!r}")
            if item.get("id") == request_id:
                return item
        raise RuntimeError(f"Timed out waiting for MCP request {request_id}")

    try:
        send("initialize", request_id=1, params={
            "protocolVersion": "2025-06-18",
            "capabilities": {},
            "clientInfo": {"name": "bootstrap-ci", "version": "1.0"},
        })
        initialized = response(1)
        if "result" not in initialized:
            raise RuntimeError(f"Real MCP handshake failed: {initialized!r}")

        send("notifications/initialized")
        send("tools/list", request_id=2, params={})
        listed = response(2)
        if "result" not in listed:
            raise RuntimeError(f"Tool listing failed: {listed!r}")
        names = {item["name"] for item in listed["result"].get("tools", [])}
        expected = {"query_graph", "get_node", "get_neighbors", "shortest_path", "graph_stats"}
        if names != expected:
            raise RuntimeError(f"Unexpected real tool list: {names!r}, expected {expected!r}")

        send("resources/read", request_id=3, params={"uri": "file:///no-access"})
        send("tools/call", request_id=4, params={
            "name": "query_graph",
            "arguments": {"project_path": str(project.parent), "query": "double"},
        })
        for request_id in (3, 4):
            denied = response(request_id)
            if "error" not in denied:
                raise RuntimeError(f"Request {request_id} was not denied: {denied!r}")
    finally:
        try:
            proc.stdin.close()
        except OSError:
            pass
        try:
            proc.wait(timeout=25)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()
    if proc.returncode:
        errors = proc.stderr.read()
        raise RuntimeError(f"Graphify proxy exit {proc.returncode}: {errors[-4000:]}")
    print("Real Graphify MCP integration passed: ordered handshake, profile, denied methods and cross-project access")
