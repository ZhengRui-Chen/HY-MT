# HY-MT Model Bootstrap Design

**Goal:** Consolidate the HY-MT model under this repository's `models/` directory and provide a supported download script so future setups do not depend on sibling repositories.

**Chosen Approach:** Keep the existing `models/` convention, migrate the existing local model from `../glint/models/HY-MT1.5-1.8B-4bit`, and add a small shell script that downloads the default Hugging Face model into `models/HY-MT1.5-1.8B-4bit`.

**Why this approach:**

- Preserves the current service and smoke-test paths
- Avoids cross-repo symlinks and hidden coupling
- Gives both a one-time migration path and a clean bootstrap path for new machines

**Download behavior:**

- Default repo: `mlx-community/HY-MT1.5-1.8B-4bit`
- Default target: `models/HY-MT1.5-1.8B-4bit`
- Prefer `hf download --local-dir`
- Fall back to `huggingface-cli download --local-dir`
- If neither CLI is available, instruct the user to run `uv sync` or install `huggingface_hub`

**Testing strategy:**

- Add subprocess tests with fake `hf` / `huggingface-cli` shims
- Verify default command construction and target directory creation
- Verify fallback to `huggingface-cli`
- Verify a clear error when no supported CLI is available
