#!/usr/bin/env zsh
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
MODEL_REPO="${MODEL_REPO:-mlx-community/HY-MT1.5-1.8B-4bit}"
MODEL_DIR_VALUE="${MODEL_DIR:-models/HY-MT1.5-1.8B-4bit}"

resolve_path() {
  local value="$1"
  if [[ "${value}" = /* ]]; then
    printf '%s\n' "${value}"
  else
    printf '%s\n' "${ROOT_DIR}/${value}"
  fi
}

MODEL_DIR=$(resolve_path "${MODEL_DIR_VALUE}")

if command -v hf >/dev/null 2>&1; then
  CLI_BIN="hf"
elif command -v huggingface-cli >/dev/null 2>&1; then
  CLI_BIN="huggingface-cli"
elif [[ -x "${ROOT_DIR}/.venv/bin/hf" ]]; then
  CLI_BIN="${ROOT_DIR}/.venv/bin/hf"
elif [[ -x "${ROOT_DIR}/.venv/bin/huggingface-cli" ]]; then
  CLI_BIN="${ROOT_DIR}/.venv/bin/huggingface-cli"
else
  cat >&2 <<EOF
No Hugging Face download CLI found.
Run \`uv sync\` first, or install \`huggingface_hub\` so that \`hf\` or \`huggingface-cli\` is available.
If the model requires authentication, run \`hf auth login\` before downloading.
EOF
  exit 1
fi

mkdir -p "${MODEL_DIR}"
echo "Downloading ${MODEL_REPO} -> ${MODEL_DIR}"
"${CLI_BIN}" download "${MODEL_REPO}" --local-dir "${MODEL_DIR}"
echo "Model download complete: ${MODEL_DIR}"
