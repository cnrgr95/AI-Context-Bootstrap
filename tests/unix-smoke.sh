#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
temp="$(mktemp -d)"
trap 'rm -rf "$temp"' EXIT
export HOME="$temp/home"
mkdir -p "$HOME/.local/bin" "$temp/project"
git -C "$temp/project" init -q
printf '<?php function hello() { return 1; }\n' > "$temp/project/hello.php"
printf '{"mcpServers":{"keep":{"command":"example"}}}\n' > "$temp/project/.mcp.json"
printf '[mcp_servers.other]\ncommand = "example"\n' > "$temp/project/.codex-config-seed"
mkdir -p "$temp/project/.codex"
cp "$temp/project/.codex-config-seed" "$temp/project/.codex/config.toml"

cat > "$HOME/.local/bin/uv" <<'SH'
#!/usr/bin/env bash
exit 0
SH
cat > "$HOME/.local/bin/graphify" <<'SH'
#!/usr/bin/env bash
case "$1" in
  extract) if [[ "${FAIL_GRAPHIFY_EXTRACT:-}" == "1" ]]; then exit 42; fi; mkdir -p graphify-out; printf '{"nodes":[],"edges":[]}\n' > graphify-out/graph.json ;;
  cluster-only|hook) ;;
  query) echo "$@" ;;
  *) exit 1 ;;
esac
SH
cp "$HOME/.local/bin/uv" "$HOME/.local/bin/graphify-mcp"
chmod +x "$HOME/.local/bin/"*

for language in EN TR; do
  for platform in Linux macOS; do
    package="$repo/$language/$platform"
    for pass in 1 2; do
      bash "$package/setup-ai-context.sh" "$temp/project" --profile Minimal --no-watcher
    done
    printf '\n' | bash "$package/INSTALL.sh" "$temp/project" --no-watcher
    bash "$package/CHECK_STATUS.sh" "$temp/project"
  done
done
bash "$repo/EN/Linux/check-status.sh" "$temp/project"
python3 - "$temp/project" "$HOME" <<'PY'
import json, pathlib, sys
root, home = map(pathlib.Path, sys.argv[1:])
assert "keep" in json.loads((root/".mcp.json").read_text())["mcpServers"]
assert (root/".codex/config.toml").read_text().count("[mcp_servers.graphify]") == 1
assert "[mcp_servers.other]" in (root/".codex/config.toml").read_text()
assert (root/"AGENTS.md").read_text().count("<!-- BEGIN AI-CONTEXT-BOOTSTRAP -->") == 1
assert "Minimal" in (root/".codex/cloud/setup.sh").read_text()
assert not (root/".codex/graphify-mcp-proxy.py").exists()
config = json.loads((root/".cursor/mcp.json").read_text())["mcpServers"]["graphify"]
assert "graphify-mcp-proxy.py" in config["args"][0]
assert pathlib.Path(config["args"][0]).is_file()
assert not pathlib.Path(config["args"][0]).is_relative_to(root)
assert (pathlib.Path(config["args"][0]).parent.stat().st_mode & 0o077) == 0
assert config["args"][-2] == "Minimal"
assert "laravel-boost" not in json.loads((root/".mcp.json").read_text())["mcpServers"]
assert len(json.loads((home/".gemini/config/mcp_config.json").read_text())["mcpServers"]) == 1
PY
for file in "$temp/project/.codex/cloud/"*.sh; do bash -n "$file"; done
for language in EN TR; do
  for platform in Windows Linux macOS; do
    query="$repo/$language/$platform/cloud/query.sh"
    bash "$query" "dependency question" 800 | grep -q -- '--budget 800'
    if bash "$query" "dependency question" not-a-number >/dev/null 2>&1; then
      echo "Invalid token budget was accepted: $query" >&2
      exit 1
    fi
    if bash "$query" "dependency question" 20000 >/dev/null 2>&1; then
      echo "Excessive token budget was accepted: $query" >&2
      exit 1
    fi
  done
done
trusted_proxy="$(python3 - "$temp/project/.cursor/mcp.json" <<'PY'
import json,sys
print(json.load(open(sys.argv[1]))["mcpServers"]["graphify"]["args"][0])
PY
)"
cp "$trusted_proxy" "$temp/proxy-backup"
rm "$trusted_proxy"
if bash "$repo/EN/Linux/check-status.sh" "$temp/project" >/dev/null 2>&1; then
  echo "Status checker ignored missing MCP proxy." >&2
  exit 1
fi
cp "$temp/proxy-backup" "$trusted_proxy"
# A failed re-install must roll back user configuration.
cp "$temp/project/.mcp.json" "$temp/snapshot-mcp"
cp "$temp/project/.codex/config.toml" "$temp/snapshot-toml"
cp "$temp/project/AGENTS.md" "$temp/snapshot-agent"
cp "$HOME/.gemini/config/mcp_config.json" "$temp/snapshot-global"
if FAIL_GRAPHIFY_EXTRACT=1 bash "$repo/EN/Linux/setup-ai-context.sh" "$temp/project" --profile Full --no-watcher >/dev/null 2>&1; then
  echo "Installer reported success despite failed extraction." >&2
  exit 1
fi
cmp "$temp/project/.mcp.json" "$temp/snapshot-mcp"
cmp "$temp/project/.codex/config.toml" "$temp/snapshot-toml"
cmp "$temp/project/AGENTS.md" "$temp/snapshot-agent"
cmp "$HOME/.gemini/config/mcp_config.json" "$temp/snapshot-global"

# A third-party server with a colliding name must be preserved.
mkdir -p "$temp/collision"
git -C "$temp/collision" init -q
printf '{"mcpServers":{"graphify":{"command":"external","cwd":"/another/project"}}}\n' > "$temp/collision/.mcp.json"
cp "$temp/collision/.mcp.json" "$temp/collision-original"
if bash "$repo/EN/Linux/setup-ai-context.sh" "$temp/collision" --profile Minimal --no-watcher >/dev/null 2>&1; then
  echo "Installer unexpectedly replaced an external MCP server." >&2
  exit 1
fi
cmp "$temp/collision/.mcp.json" "$temp/collision-original"
test ! -f "$temp/collision/.codex/graphify-mcp-proxy.py"

# Regression: an existing, unmarked Codex table must never be duplicated.
mkdir -p "$temp/unmanaged/.codex"
git -C "$temp/unmanaged" init -q
printf '[mcp_servers.graphify]\ncommand = "external"\n' > "$temp/unmanaged/.codex/config.toml"
cp "$temp/unmanaged/.codex/config.toml" "$temp/unmanaged-original"
if bash "$repo/EN/Linux/setup-ai-context.sh" "$temp/unmanaged" --profile Minimal --no-watcher >/dev/null 2>&1; then
  echo "Unmanaged Codex Graphify table was overwritten." >&2
  exit 1
fi
cmp "$temp/unmanaged/.codex/config.toml" "$temp/unmanaged-original"
python3 - "$temp/unmanaged/.codex/config.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], "rb") as f:
    assert tomllib.load(f)["mcp_servers"]["graphify"]["command"] == "external"
PY

# Regression: parent directory symlinks cannot redirect installer writes.
mkdir -p "$temp/redirect-project" "$temp/redirect-target"
git -C "$temp/redirect-project" init -q
ln -s "$temp/redirect-target" "$temp/redirect-project/.codex"
if bash "$repo/TR/macOS/setup-ai-context.sh" "$temp/redirect-project" --profile Minimal --no-watcher >/dev/null 2>&1; then
  echo "Installer accepted a redirected .codex directory." >&2
  exit 1
fi
test ! -e "$temp/redirect-target/graphify-mcp-proxy.py"

echo 'Unix installer smoke test passed.'
