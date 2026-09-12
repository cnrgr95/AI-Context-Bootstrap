#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <project-path> [--profile Minimal|Balanced|Full] [--skip-laravel-boost] [--no-watcher]"
}

[[ $# -ge 1 ]] || { usage; exit 2; }
project_input="$1"; shift
profile="Minimal"; skip_boost=0; no_watcher=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile="${2:-}"; shift 2 ;;
    --skip-laravel-boost) skip_boost=1; shift ;;
    --no-watcher) no_watcher=1; shift ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done
case "$profile" in Minimal|Balanced|Full) ;; *) echo "Invalid profile: $profile" >&2; exit 2 ;; esac

command -v git >/dev/null || { echo "Git is required." >&2; exit 1; }
command -v python3 >/dev/null || { echo "Python 3.10+ is required." >&2; exit 1; }
python3 -c 'import sys; assert sys.version_info >= (3,10)' || { echo "Python 3.10+ is required." >&2; exit 1; }
project="$(cd "$project_input" && pwd -P)"
script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
slug="$(printf '%s' "$(basename "$project")" | tr -cs '[:alnum:]_-' '-' | tr '[:upper:]' '[:lower:]')"
path_hash="$(python3 - "$project" <<'PY'
import hashlib, sys
print(hashlib.sha256(sys.argv[1].lower().encode()).hexdigest()[:8])
PY
)"
project_id="${slug}-${path_hash}"

export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null; then
  command -v curl >/dev/null || { echo "curl is required to install uv." >&2; exit 1; }
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
if ! command -v graphify >/dev/null || ! command -v graphify-mcp >/dev/null; then
  uv tool install 'graphifyy[mcp,watch]' --with 'mcp<2>'
fi
command -v graphify >/dev/null && command -v graphify-mcp >/dev/null || { echo "Graphify executables were not found." >&2; exit 1; }
graphify_bin="$(command -v graphify)"
graphify_mcp_bin="$(command -v graphify-mcp)"

cd "$project"
mkdir -p .cursor .codex/cloud .agents/rules
python3 - "$project" "$project_id" "$graphify_mcp_bin" "$profile" "$HOME" "$skip_boost" <<'PY'
import json, os, re, subprocess, sys
from pathlib import Path

project, project_id, graphify_mcp, profile, home, skip_boost = sys.argv[1:]
root = Path(project)

def add_lines(path, lines):
    p = root / path
    current = p.read_text(encoding="utf-8").splitlines() if p.exists() else []
    for line in lines:
        if line not in current: current.append(line)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text("\n".join(current).rstrip() + "\n", encoding="utf-8")

def read_json(path):
    p = Path(path)
    if not p.exists() or not p.read_text(encoding="utf-8").strip(): return {"mcpServers": {}}
    data = json.loads(p.read_text(encoding="utf-8")); data.setdefault("mcpServers", {})
    return data

def set_server(path, name, value):
    p = Path(path); p.parent.mkdir(parents=True, exist_ok=True)
    data = read_json(p); data["mcpServers"][name] = value
    p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

def remove_server(path, name):
    p = Path(path)
    if not p.exists(): return
    data = read_json(p); data["mcpServers"].pop(name, None)
    p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

def set_codex(path, name, command, args, cwd, tools=None):
    p = Path(path); p.parent.mkdir(parents=True, exist_ok=True)
    text = p.read_text(encoding="utf-8") if p.exists() else ""
    start, end = f"# BEGIN AI-CONTEXT-BOOTSTRAP {name.upper()}", f"# END AI-CONTEXT-BOOTSTRAP {name.upper()}"
    q = lambda x: json.dumps(str(x))
    block = [start, f"[mcp_servers.{name}]", f"command = {q(command)}", f"args = [{', '.join(q(a) for a in args)}]", f"cwd = {q(cwd)}", "startup_timeout_sec = 20", "tool_timeout_sec = 60"]
    if tools: block.append(f"enabled_tools = [{', '.join(q(t) for t in tools)}]")
    block.append(end); replacement = "\n".join(block)
    pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.S)
    if pattern.search(text):
        text = pattern.sub(replacement, text)
    else:
        table = re.compile(r"(?ms)^\[mcp_servers\." + re.escape(name) + r"\]\n.*?(?=^\[|\Z)")
        text = table.sub("", text).rstrip() + "\n\n" + replacement + "\n"
    p.write_text(text.lstrip("\n"), encoding="utf-8")

def remove_codex(path, name):
    p = Path(path)
    if not p.exists(): return
    start, end = f"# BEGIN AI-CONTEXT-BOOTSTRAP {name.upper()}", f"# END AI-CONTEXT-BOOTSTRAP {name.upper()}"
    text = re.sub(r"\n?" + re.escape(start) + r".*?" + re.escape(end) + r"\n?", "\n", p.read_text(encoding="utf-8"), flags=re.S)
    p.write_text(text.strip() + "\n", encoding="utf-8")

add_lines(".graphifyignore", ["vendor/","node_modules/","public/build/","public/storage/","storage/","graphify-out/",".env*","*.key","*.pem","*.dump","*.sql","*.sql.enc"])
add_lines(".cursorignore", ["/vendor/","/node_modules/","/graphify-out/","/public/build/","/public/storage/","/storage/logs/",".env",".env.*","*.key","*.pem","*.dump","*.sql"])
add_lines(".gitignore", ["/graphify-out/","!/.codex/","/.codex/*","!/.codex/cloud/","!/.codex/cloud/**"])

disabled = {"Minimal":["get_community","god_nodes","list_prs","get_pr_impact","triage_prs"],"Balanced":["list_prs","get_pr_impact","triage_prs"],"Full":[]}[profile]
enabled = {"Minimal":["query_graph","get_node","get_neighbors","shortest_path","graph_stats"],"Balanced":["query_graph","get_node","get_neighbors","get_community","god_nodes","shortest_path","graph_stats"],"Full":[]}[profile]
base = {"command": graphify_mcp, "args":[str(root / "graphify-out/graph.json")], "cwd":project}
set_server(root/".mcp.json", "graphify", base)
set_server(root/".cursor/mcp.json", "graphify", base)
set_server(root/".agents/mcp_config.json", f"graphify-{project_id}", {**base,"disabledTools":disabled})
set_server(Path(home)/".gemini/config/mcp_config.json", f"graphify-{project_id}", {**base,"disabledTools":disabled})
set_codex(root/".codex/config.toml", "graphify", graphify_mcp, base["args"], project, enabled)

boost = False
if skip_boost == "0" and profile != "Minimal" and (root/"artisan").exists():
    php = subprocess.run(["sh","-lc","command -v php"],capture_output=True,text=True).stdout.strip()
    if php and subprocess.run([php,"artisan","--version"],cwd=root,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode == 0:
        commands = subprocess.run([php,"artisan","list","--raw"],cwd=root,capture_output=True,text=True).stdout
        if re.search(r"(?m)^boost:mcp\b", commands):
            value={"command":php,"args":["artisan","boost:mcp"],"cwd":project}
            for p in [root/".mcp.json",root/".cursor/mcp.json",root/".agents/mcp_config.json"]: set_server(p,"laravel-boost",value)
            set_server(Path(home)/".gemini/config/mcp_config.json",f"laravel-boost-{project_id}",value)
            set_codex(root/".codex/config.toml","laravel-boost",php,["artisan","boost:mcp"],project)
            boost=True
if not boost:
    for p in [root/".mcp.json",root/".cursor/mcp.json",root/".agents/mcp_config.json"]:
        if p.exists() and read_json(p)["mcpServers"].get("laravel-boost",{}).get("cwd") == project: remove_server(p,"laravel-boost")
    global_boost=Path(home)/".gemini/config/mcp_config.json"
    if global_boost.exists() and read_json(global_boost)["mcpServers"].get(f"laravel-boost-{project_id}",{}).get("cwd") == project:
        remove_server(global_boost,f"laravel-boost-{project_id}")
    remove_codex(root/".codex/config.toml","laravel-boost")

rule = '## Efficient agent context\n\nStart with named files and search narrowly. Use Graphify MCP for cross-module questions; in Codex Cloud use `bash .codex/cloud/query.sh "question"` if MCP is unavailable. Keep the default 800-token query budget unless more detail is needed. Verify graph results against source, preserve unrelated changes, and keep secrets, dependencies, and generated output out of context.'
p=root/"AGENTS.md"; text=p.read_text(encoding="utf-8") if p.exists() else ""
start,end="<!-- BEGIN AI-CONTEXT-BOOTSTRAP -->","<!-- END AI-CONTEXT-BOOTSTRAP -->"; block=f"{start}\n{rule}\n{end}"
pattern=re.compile(re.escape(start)+r".*?"+re.escape(end),re.S)
text=pattern.sub(block,text) if pattern.search(text) else text.rstrip()+"\n\n"+block+"\n"
p.write_text(text.lstrip("\n"),encoding="utf-8")
(root/".agents/rules/efficient-context.md").write_text(rule+"\n",encoding="utf-8")
PY

for cloud_file in setup.sh maintenance.sh query.sh README.md; do
  sed "s/__DEFAULT_PROFILE__/$profile/g" "$script_root/cloud/$cloud_file" > ".codex/cloud/$cloud_file"
done
chmod +x .codex/cloud/*.sh

graphify extract . --code-only --no-cluster
[[ "$profile" == "Minimal" ]] || graphify cluster-only . --no-label --no-viz
graphify hook install

if [[ "$no_watcher" == 0 ]]; then
  case "$(uname -s)" in
    Linux)
      if command -v systemctl >/dev/null && systemctl --user show-environment >/dev/null 2>&1; then
        service="$HOME/.config/systemd/user/graphify-${project_id}.service"; mkdir -p "$(dirname "$service")"
        cat > "$service" <<EOF
[Unit]
Description=Graphify watcher for $project
[Service]
Type=simple
WorkingDirectory=$project
ExecStart=$graphify_bin watch .
Restart=on-failure
[Install]
WantedBy=default.target
EOF
        if systemctl --user daemon-reload && systemctl --user enable --now "graphify-${project_id}.service"; then
          echo "systemd watcher enabled: graphify-${project_id}.service"
        else echo "Could not enable systemd watcher; Git hooks will refresh the graph." >&2; fi
      else echo "systemd user services unavailable; Git hooks will refresh the graph."; fi
      ;;
    Darwin)
      plist="$HOME/Library/LaunchAgents/com.graphify.${project_id}.plist"; mkdir -p "$(dirname "$plist")"
      python3 - "$plist" "$graphify_bin" "$project" "$project_id" <<'PY'
import plistlib, sys
path, binary, project, project_id = sys.argv[1:]
data={"Label":"com.graphify."+project_id,"ProgramArguments":[binary,"watch","."],"WorkingDirectory":project,"RunAtLoad":True,"KeepAlive":True}
with open(path,"wb") as f: plistlib.dump(data,f)
PY
      launchctl bootout "gui/$(id -u)" "$plist" >/dev/null 2>&1 || true
      if launchctl bootstrap "gui/$(id -u)" "$plist"; then
        echo "LaunchAgent watcher enabled: com.graphify.${project_id}"
      else echo "Could not enable LaunchAgent; Git hooks will refresh the graph." >&2; fi
      ;;
    *) echo "Unsupported watcher platform; Git hooks will refresh the graph." ;;
  esac
fi

echo "Ready: $project"
echo "Platform: $(uname -s) | Profile: $profile | Project ID: $project_id"
echo "Restart Codex, Cursor, and Antigravity or refresh their MCP lists."
