# oMLX Bootstrap Script Design

**Goal:** Add a repository-local bootstrap script that installs `omlx` into the expected `.venv-omlx` environment using `uv`, so service startup no longer depends on undocumented manual setup.

**Chosen Approach:** Clone or update the upstream `jundot/omlx` repository into a local runtime directory, create `.venv-omlx` with `uv`, install the source checkout in editable mode, then prepare default local config and model directories.

**Why this approach:**

- Matches the current startup contract in `scripts/start_omlx.sh`
- Keeps HY-MT app dependencies separate from the oMLX runtime
- Allows repeatable re-runs for upgrades or machine bootstrap
- Avoids assuming `omlx` is available in the user's global environment

**Script responsibilities:**

- Clone `https://github.com/jundot/omlx` when the local source checkout does not exist
- Run `git pull --ff-only` when the source checkout already exists
- Create `.venv-omlx` with `uv venv`
- Install `omlx` into that environment with `uv pip install --python ... -e ...`
- Create `configs/omlx.env` from the example when absent
- Create the model directory when absent
- Fail clearly if `.venv-omlx/bin/omlx` is still missing after install

**Path overrides for testability:**

- `OMLX_REPO_URL`
- `OMLX_SOURCE_DIR`
- `OMLX_VENV_DIR`
- `OMLX_CONFIG_FILE`
- `OMLX_MODEL_DIR`

**Testing strategy:**

- Add shell-level pytest coverage that runs the setup script through `subprocess`
- Stub `git` and `uv` via `PATH` to avoid network calls
- Verify fresh bootstrap creates the expected files
- Verify reruns update an existing checkout instead of cloning again
