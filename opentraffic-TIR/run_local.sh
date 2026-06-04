#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PYTHON="$ROOT_DIR/.venv/bin/python"
REDIS_SERVER_BIN="$ROOT_DIR/redis-7.4.0/src/redis-server"
REDIS_CLI_BIN="${REDIS_CLI_BIN:-redis-cli}"
REDIS_HOST="${REDIS_HOST:-127.0.0.1}"
REDIS_PORT="${REDIS_PORT:-6379}"
JSONL_OUT_DIR="$ROOT_DIR/control_group_fullspeed_jsonl"

if [[ ! -x "$VENV_PYTHON" ]]; then
  echo "missing python: $VENV_PYTHON" >&2
  exit 1
fi

if [[ ! -x "$REDIS_SERVER_BIN" ]]; then
  echo "missing redis server: $REDIS_SERVER_BIN" >&2
  exit 1
fi

redis_ready() {
  "$REDIS_CLI_BIN" -h "$REDIS_HOST" -p "$REDIS_PORT" ping >/dev/null 2>&1
}

ensure_redis() {
  if redis_ready; then
    echo "redis already ready on ${REDIS_HOST}:${REDIS_PORT}"
    return 0
  fi

  echo "starting redis on ${REDIS_HOST}:${REDIS_PORT}"
  "$REDIS_SERVER_BIN" --daemonize yes --bind "$REDIS_HOST" --port "$REDIS_PORT" --save "" --appendonly no

  for _ in $(seq 1 20); do
    if redis_ready; then
      echo "redis started on ${REDIS_HOST}:${REDIS_PORT}"
      return 0
    fi
    sleep 0.5
  done

  echo "redis did not become ready on ${REDIS_HOST}:${REDIS_PORT}" >&2
  exit 1
}

ensure_redis

cd "$ROOT_DIR"
rm -rf "$JSONL_OUT_DIR"
exec "$VENV_PYTHON" -c "import main; t = main.Tir(); t.polling()"
