#!/usr/bin/env python3
"""Project-scoped, profile-filtered stdio proxy for the Graphify MCP server.

This narrows MCP tool exposure, but is NOT an OS sandbox. Run under a
least-privileged user and keep secrets out of the indexed repository.
"""
import json
import os
from pathlib import Path
import subprocess
import sys
import threading

PROFILES = {
    "Minimal": frozenset(("query_graph", "get_node", "get_neighbors", "shortest_path", "graph_stats")),
    "Balanced": frozenset(("query_graph", "get_node", "get_neighbors", "shortest_path", "graph_stats", "get_community", "god_nodes")),
    "Full": frozenset(("query_graph", "get_node", "get_neighbors", "shortest_path", "graph_stats", "get_community", "god_nodes", "list_prs", "get_pr_impact", "triage_prs")),
}


def identifier(value):
    return json.dumps(value, sort_keys=True, ensure_ascii=True)


def same_directory(first, second):
    try:
        a = os.path.normcase(str(Path(first).resolve(strict=True)))
        b = os.path.normcase(str(Path(second).resolve(strict=True)))
        return a == b
    except (OSError, TypeError, ValueError):
        return False


def main():
    if len(sys.argv) != 5 or sys.argv[3] not in PROFILES:
        print("Usage: graphify-mcp-proxy.py <backend-executable> <graph-file> <Minimal|Balanced|Full> <project-root>", file=sys.stderr)
        return 2

    backend_path, graph_path, profile, project_root = sys.argv[1:]
    if not Path(project_root).is_dir() or not same_directory(Path(graph_path).parent.parent, project_root):
        print("Graph path must reside in the selected project's graphify-out directory", file=sys.stderr)
        return 2
    if Path(graph_path).parent.name != "graphify-out":
        print("Expected graphify-out/graph.json", file=sys.stderr)
        return 2

    allowed = PROFILES[profile]
    # Graphify context integration exposes tools only. Other optional MCP
    # capabilities must not bypass the configured tool allowlist.
    permitted_methods = frozenset((
        "initialize", "ping", "tools/list", "tools/call",
        "notifications/initialized", "notifications/cancelled",
    ))
    pending_lists = set()
    pending_lock = threading.Lock()
    output_lock = threading.Lock()

    try:
        child = subprocess.Popen(
            [backend_path, graph_path],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=sys.stderr,
            cwd=project_root,
            bufsize=0,
        )
    except OSError as exc:
        print("Cannot start Graphify MCP server: " + str(exc), file=sys.stderr)
        return 1

    def emit(payload):
        with output_lock:
            sys.stdout.buffer.write(payload)
            sys.stdout.buffer.flush()

    def reply_error(request, message, code=-32602):
        if "id" not in request:
            return
        response = {"jsonrpc": "2.0", "id": request["id"], "error": {"code": code, "message": message}}
        emit((json.dumps(response, separators=(",", ":")) + "\n").encode("utf-8"))

    def relay_responses():
        for line in child.stdout:
            try:
                message = json.loads(line)
                key = identifier(message.get("id")) if isinstance(message, dict) and "id" in message else None
                with pending_lock:
                    is_list = key in pending_lists if key is not None else False
                    if is_list:
                        pending_lists.remove(key)
                if is_list:
                    result = message.get("result")
                    if isinstance(result, dict) and isinstance(result.get("tools"), list):
                        result["tools"] = [
                            tool for tool in result["tools"]
                            if isinstance(tool, dict) and tool.get("name") in allowed
                        ]
                        line = (json.dumps(message, separators=(",", ":")) + "\n").encode("utf-8")
            except (ValueError, TypeError, AttributeError):
                # Non-JSON output must not be treated as a tool list.
                pass
            emit(line)

    reader = threading.Thread(target=relay_responses, daemon=True)
    reader.start()
    try:
        for line in sys.stdin.buffer:
            try:
                request = json.loads(line)
            except ValueError:
                # Invalid input is never forwarded to the privileged backend.
                continue
            if not isinstance(request, dict):
                continue
            method = request.get("method")
            if method is not None and method not in permitted_methods:
                reply_error(request, "MCP method not permitted by Graphify proxy", -32601)
                continue
            if method == "tools/call":
                params = request.get("params")
                if not isinstance(params, dict) or params.get("name") not in allowed:
                    reply_error(request, "Tool not allowed by Graphify profile: " + profile)
                    continue
                arguments = params.get("arguments", {})
                if not isinstance(arguments, dict):
                    reply_error(request, "Invalid tool arguments")
                    continue
                # Graphify accepts project_path to query other repositories.
                # Never let clients cross the selected project boundary.
                if "project_path" in arguments and not same_directory(arguments["project_path"], project_root):
                    reply_error(request, "Cross-project Graphify access denied")
                    continue
            if method == "tools/list" and "id" in request:
                with pending_lock:
                    pending_lists.add(identifier(request["id"]))
            try:
                child.stdin.write(line)
                child.stdin.flush()
            except (OSError, BrokenPipeError):
                break
    finally:
        try:
            child.stdin.close()
        except OSError:
            pass
        reader.join(timeout=4)
        if child.poll() is None:
            child.terminate()
            try:
                child.wait(timeout=2)
            except subprocess.TimeoutExpired:
                child.kill()
                child.wait()
    return 0


if __name__ == "__main__":
    sys.exit(main())
