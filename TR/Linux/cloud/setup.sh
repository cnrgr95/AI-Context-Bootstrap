#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"
export PATH="$HOME/.local/bin:$PATH"
profile="${AI_CONTEXT_PROFILE:-__DEFAULT_PROFILE__}"

case "$profile" in
  Minimal|Balanced|Full) ;;
  *) echo "AI_CONTEXT_PROFILE must be Minimal, Balanced, or Full." >&2; exit 2 ;;
esac

if ! python3 -c 'import graphify, mcp, watchdog' >/dev/null 2>&1; then
  python3 -m pip install --user --upgrade 'graphifyy[mcp,watch]' 'mcp<2'
fi

if ! command -v graphify >/dev/null 2>&1; then
  echo "graphify is unavailable after installation." >&2
  exit 1
fi

graphify extract . --code-only --no-cluster
if [[ "$profile" != "Minimal" ]]; then
  graphify cluster-only . --no-label --no-viz
fi

echo "Codex Cloud context is ready ($profile)."
echo "Use: bash .codex/cloud/query.sh \"your architecture question\""
