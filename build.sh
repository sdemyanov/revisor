#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

rm -f revisor.plugin
zip -r revisor.plugin .claude-plugin/ skills/ scheduled/ README.md LICENSE \
  -x "*.DS_Store" "*/__pycache__/*" "*.pyc"

echo "Built revisor.plugin ($(du -h revisor.plugin | cut -f1))"
