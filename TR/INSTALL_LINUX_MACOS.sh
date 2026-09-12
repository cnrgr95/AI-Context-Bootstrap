#!/usr/bin/env bash
set -euo pipefail
project="${1:-}"
[[ -n "$project" ]] || read -r -p "Proje klasörünün tam yolunu girin: " project
echo "1. Minimal (önerilen, en düşük araç bağlamı)"
echo "2. Dengeli (Graphify + varsa Laravel Boost)"
echo "3. Tam (tüm Graphify araçları + Laravel Boost)"
read -r -p "Profil [1]: " choice
case "${choice:-1}" in 2) profile=Balanced;; 3) profile=Full;; *) profile=Minimal;; esac
bash "$(cd "$(dirname "$0")/.." && pwd)/setup-ai-context.sh" "$project" --profile "$profile"
