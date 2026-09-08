#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PYTHON="${PYTHON:-python3}"
"$PYTHON" -m compileall -q "$ROOT_DIR/src" "$ROOT_DIR/tests"
"$PYTHON" -m unittest discover -s "$ROOT_DIR/tests" -v
