#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo 'Usage: bash .codex/cloud/query.sh "question" [token-budget]' >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"
export PATH="$HOME/.local/bin:$PATH"
budget="${2:-800}"
if ! [[ "$budget" =~ ^[1-9][0-9]{0,4}$ ]] || (( 10#$budget > 16000 )); then
  echo "Token budget must be an integer from 1 to 16000." >&2
  exit 2
fi

graphify query "$1" --budget "$budget" --graph graphify-out/graph.json
