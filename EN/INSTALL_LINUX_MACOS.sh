#!/usr/bin/env bash
set -euo pipefail
project="${1:-}"
[[ -n "$project" ]] || read -r -p "Enter the full project directory: " project
echo "1. Minimal (recommended, smallest tool context)"
echo "2. Balanced (Graphify + Laravel Boost when available)"
echo "3. Full (all Graphify tools + Laravel Boost)"
read -r -p "Profile [1]: " choice
case "${choice:-1}" in 2) profile=Balanced;; 3) profile=Full;; *) profile=Minimal;; esac
bash "$(cd "$(dirname "$0")/.." && pwd)/setup-ai-context.sh" "$project" --profile "$profile"
