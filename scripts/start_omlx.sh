#!/usr/bin/env zsh
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
ENV_FILE="${ROOT_DIR}/configs/omlx.env"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  source "${ENV_FILE}"
  set +a
fi

MODEL_DIR="${ROOT_DIR}/${OMLX_MODEL_DIR:-models}"
HOST="${OMLX_HOST:-127.0.0.1}"
PORT="${OMLX_PORT:-8001}"
API_KEY="${OMLX_API_KEY:-local-hy-key}"
BASE_PATH="${OMLX_BASE_PATH:-${HOME}/.omlx}"
DEFAULT_OMLX_BIN="${ROOT_DIR}/.venv-omlx/bin/omlx"
OMLX_BIN="${OMLX_BIN:-${DEFAULT_OMLX_BIN}}"

if [[ ! -x "${OMLX_BIN}" ]]; then
  SYSTEM_OMLX=$(command -v omlx 2>/dev/null || true)
  if [[ -n "${SYSTEM_OMLX}" ]]; then
    OMLX_BIN="${SYSTEM_OMLX}"
  else
    cat >&2 <<EOF
oMLX binary not found.
Checked:
  - ${DEFAULT_OMLX_BIN}
  - \$OMLX_BIN (${OMLX_BIN})
  - omlx in PATH

Install oMLX first, or set OMLX_BIN to an existing executable path.
Official source install: https://omlx.ai/
EOF
    exit 1
  fi
fi

exec "${OMLX_BIN}" serve \
  --model-dir "${MODEL_DIR}" \
  --host "${HOST}" \
  --port "${PORT}" \
  --api-key "${API_KEY}" \
  --base-path "${BASE_PATH}" \
  --no-cache
