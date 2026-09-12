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
  extract) mkdir -p graphify-out; printf '{"nodes":[],"edges":[]}\n' > graphify-out/graph.json ;;
  cluster-only|hook) ;;
  *) exit 1 ;;
esac
SH
cp "$HOME/.local/bin/uv" "$HOME/.local/bin/graphify-mcp"
chmod +x "$HOME/.local/bin/"*

for pass in 1 2; do
  bash "$repo/setup-ai-context.sh" "$temp/project" --profile Minimal --no-watcher
done
for platform in Linux macOS; do
  for language in EN TR; do
    printf '\n' | bash "$repo/$platform/$language/INSTALL.sh" "$temp/project" --no-watcher
    bash "$repo/$platform/$language/CHECK_STATUS.sh" "$temp/project"
  done
done
bash "$repo/check-status.sh" "$temp/project"
python3 - "$temp/project" "$HOME" <<'PY'
import json, pathlib, sys
root, home = map(pathlib.Path, sys.argv[1:])
assert "keep" in json.loads((root/".mcp.json").read_text())["mcpServers"]
assert (root/".codex/config.toml").read_text().count("[mcp_servers.graphify]") == 1
assert "[mcp_servers.other]" in (root/".codex/config.toml").read_text()
assert (root/"AGENTS.md").read_text().count("<!-- BEGIN AI-CONTEXT-BOOTSTRAP -->") == 1
assert "Minimal" in (root/".codex/cloud/setup.sh").read_text()
assert len(json.loads((home/".gemini/config/mcp_config.json").read_text())["mcpServers"]) == 1
PY
for file in "$temp/project/.codex/cloud/"*.sh; do bash -n "$file"; done
echo 'Unix installer smoke test passed.'
