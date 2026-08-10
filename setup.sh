#!/usr/bin/env bash
# falling-sand — serve the single-page sim
set -euo pipefail
cd "$(dirname "$0")"
PORT="${PORT:-8765}"
echo "Falling Sand → http://127.0.0.1:${PORT}/"
echo "Ctrl+C to stop."
exec python3 -m http.server "$PORT" --bind 127.0.0.1
