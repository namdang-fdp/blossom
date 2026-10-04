#!/usr/bin/env bash
set -euo pipefail
if ! command -v pre-commit >/dev/null; then
  echo "Cần cài pre-commit để bật Git hooks." >&2
  exit 1
fi
pre-commit install
