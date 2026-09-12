#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v graphify >/dev/null 2>&1 || [[ ! -f graphify-out/graph.json ]]; then
  exec bash .codex/cloud/setup.sh
fi

graphify update . --no-cluster
if [[ "${AI_CONTEXT_PROFILE:-__DEFAULT_PROFILE__}" != "Minimal" ]]; then
  graphify cluster-only . --no-label --no-viz
fi
