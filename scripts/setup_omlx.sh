#!/usr/bin/env zsh
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
OMLX_REPO_URL="${OMLX_REPO_URL:-https://github.com/jundot/omlx}"
OMLX_SOURCE_DIR="${OMLX_SOURCE_DIR:-${ROOT_DIR}/.runtime/omlx/source}"
OMLX_VENV_DIR="${OMLX_VENV_DIR:-${ROOT_DIR}/.venv-omlx}"
OMLX_CONFIG_FILE="${OMLX_CONFIG_FILE:-${ROOT_DIR}/configs/omlx.env}"
MODEL_DIR_VALUE="${OMLX_MODEL_DIR:-models}"

resolve_path() {
  local value="$1"
  if [[ "${value}" = /* ]]; then
    printf '%s\n' "${value}"
  else
    printf '%s\n' "${ROOT_DIR}/${value}"
  fi
}

MODEL_DIR=$(resolve_path "${MODEL_DIR_VALUE}")

if [[ -e "${OMLX_SOURCE_DIR}" && ! -d "${OMLX_SOURCE_DIR}/.git" ]]; then
  echo "Existing OMLX_SOURCE_DIR is not a git checkout: ${OMLX_SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "$(dirname "${OMLX_SOURCE_DIR}")"
if [[ -d "${OMLX_SOURCE_DIR}/.git" ]]; then
  echo "Updating oMLX source checkout: ${OMLX_SOURCE_DIR}"
  git -C "${OMLX_SOURCE_DIR}" pull --ff-only
else
  echo "Cloning oMLX source: ${OMLX_REPO_URL} -> ${OMLX_SOURCE_DIR}"
  git clone "${OMLX_REPO_URL}" "${OMLX_SOURCE_DIR}"
fi

echo "Creating uv environment: ${OMLX_VENV_DIR}"
uv venv "${OMLX_VENV_DIR}"

echo "Installing oMLX into: ${OMLX_VENV_DIR}"
uv pip install --python "${OMLX_VENV_DIR}/bin/python" -e "${OMLX_SOURCE_DIR}"

if [[ ! -x "${OMLX_VENV_DIR}/bin/omlx" ]]; then
  echo "Expected oMLX binary missing after install: ${OMLX_VENV_DIR}/bin/omlx" >&2
  exit 1
fi

if [[ ! -f "${OMLX_CONFIG_FILE}" ]]; then
  mkdir -p "$(dirname "${OMLX_CONFIG_FILE}")"
  cp "${ROOT_DIR}/configs/omlx.env.example" "${OMLX_CONFIG_FILE}"
  echo "Created config file: ${OMLX_CONFIG_FILE}"
fi

mkdir -p "${MODEL_DIR}"
echo "Ensured model directory exists: ${MODEL_DIR}"
echo "oMLX bootstrap complete."
