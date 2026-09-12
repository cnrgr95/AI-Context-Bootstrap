#!/usr/bin/env bash
set -euo pipefail
project="${1:-}"
[[ -n "$project" ]] || read -r -p "Proje klasörünün tam yolunu girin: " project
bash "$(cd "$(dirname "$0")" && pwd)/check-status.sh" "$project"
