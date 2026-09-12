#!/usr/bin/env bash
set -euo pipefail
[[ $# -eq 1 ]] || { echo "Usage: $0 <project-path>" >&2; exit 2; }
project="$(cd "$1" && pwd -P)"; failed=0
export PATH="$HOME/.local/bin:$PATH"
check(){ if [[ -e "$2" ]]; then printf '%-20s OK\n' "$1"; else printf '%-20s MISSING\n' "$1"; failed=1; fi; }
check Project "$project"
check Graph "$project/graphify-out/graph.json"
check CursorMcp "$project/.cursor/mcp.json"
check CodexMcp "$project/.codex/config.toml"
check CodexCloud "$project/.codex/cloud/setup.sh"
check AntigravityMcp "$project/.agents/mcp_config.json"
command -v graphify >/dev/null && printf '%-20s OK\n' GraphifyCommand || { printf '%-20s MISSING\n' GraphifyCommand; failed=1; }
slug="$(printf '%s' "$(basename "$project")" | tr -cs '[:alnum:]_-' '-' | tr '[:upper:]' '[:lower:]')"
hash="$(python3 - "$project" <<'PY'
import hashlib, sys
print(hashlib.sha256(sys.argv[1].lower().encode()).hexdigest()[:8])
PY
)"
case "$(uname -s)" in
  Linux)
    if command -v systemctl >/dev/null && systemctl --user is-active --quiet "graphify-${slug}-${hash}.service"; then
      printf '%-20s RUNNING\n' Watcher
    else printf '%-20s NOT RUNNING (Git hooks available)\n' Watcher; fi ;;
  Darwin)
    if launchctl print "gui/$(id -u)/com.graphify.${slug}-${hash}" >/dev/null 2>&1; then
      printf '%-20s RUNNING\n' Watcher
    else printf '%-20s NOT RUNNING (Git hooks available)\n' Watcher; fi ;;
esac
exit "$failed"
