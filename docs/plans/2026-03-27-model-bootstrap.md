# HY-MT Model Bootstrap Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Move the existing HY-MT model into this repository and add a standard download script for future setups.

**Architecture:** Keep all runtime code pointing at `models/`. Add one shell script for model download and update the setup docs to describe both migration and download workflows.

**Tech Stack:** `zsh`, `pytest`, Hugging Face CLI

---

### Task 1: Add failing tests for the download script

**Files:**
- Create: `tests/test_download_model.py`
- Test: `tests/test_download_model.py`

**Step 1: Write the failing test**

```python
def test_download_model_uses_hf_cli_and_default_target():
    ...
```

**Step 2: Run test to verify it fails**

Run: `uv run pytest tests/test_download_model.py -v`
Expected: FAIL because `scripts/download_model.sh` does not exist yet.

**Step 3: Write minimal implementation**

Create the script after seeing the expected failure.

**Step 4: Run test to verify it passes**

Run: `uv run pytest tests/test_download_model.py -v`
Expected: PASS

### Task 2: Implement the download script and docs

**Files:**
- Create: `scripts/download_model.sh`
- Modify: `README.md`
- Test: `tests/test_download_model.py`

**Step 1: Write the failing test**

```python
def test_download_model_falls_back_to_huggingface_cli():
    ...
```

**Step 2: Run test to verify it fails**

Run: `uv run pytest tests/test_download_model.py -v`
Expected: FAIL because fallback behavior is not yet implemented.

**Step 3: Write minimal implementation**

Implement:
- default repo and target dir
- CLI detection
- `download --local-dir` invocation
- clear setup error when no CLI exists

**Step 4: Run test to verify it passes**

Run: `uv run pytest tests/test_download_model.py -v`
Expected: PASS

### Task 3: Migrate the local model and run regression checks

**Files:**
- Move: `../glint/models/HY-MT1.5-1.8B-4bit -> models/HY-MT1.5-1.8B-4bit`
- Test: `tests/test_download_model.py`
- Test: `tests/test_setup_omlx.py`
- Test: `tests/test_start_omlx.py`

**Step 1: Move the local model directory**

Run: `mkdir -p models && mv ../glint/models/HY-MT1.5-1.8B-4bit models/`
Expected: Model now lives under this repository.

**Step 2: Run focused tests**

Run: `uv run pytest tests/test_download_model.py tests/test_setup_omlx.py tests/test_start_omlx.py -v`
Expected: PASS

**Step 3: Run full test suite**

Run: `uv run pytest`
Expected: PASS
