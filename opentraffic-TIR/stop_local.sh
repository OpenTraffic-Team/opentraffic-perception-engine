#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PYTHON="$ROOT_DIR/.venv/bin/python -c import main"
REDIS_BIN="$ROOT_DIR/redis-7.4.0/src/redis-server"

stop_matching() {
  local pattern="$1"
  local label="$2"

  if pgrep -f "$pattern" >/dev/null 2>&1; then
    pkill -TERM -f "$pattern" || true
    for _ in $(seq 1 20); do
      if ! pgrep -f "$pattern" >/dev/null 2>&1; then
        echo "stopped ${label}"
        return 0
      fi
      sleep 0.5
    done
    pkill -KILL -f "$pattern" || true
    echo "force killed ${label}"
  else
    echo "no running ${label}"
  fi
}

stop_matching "$PROJECT_PYTHON" "project"
stop_matching "$REDIS_BIN" "local redis"
