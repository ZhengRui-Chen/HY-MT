# oMLX Bootstrap Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a bootstrap script that installs `omlx` into `.venv-omlx` with `uv` and prepares the local HY-MT runtime defaults.

**Architecture:** Add one repository script dedicated to bootstrapping the oMLX runtime. Keep startup behavior unchanged except that developers now have an explicit supported way to create the expected binary and local config.

**Tech Stack:** `zsh`, `uv`, `git`, `pytest`

---

### Task 1: Add failing setup-script tests

**Files:**
- Create: `tests/test_setup_omlx.py`
- Test: `tests/test_setup_omlx.py`

**Step 1: Write the failing test**

```python
def test_setup_omlx_bootstraps_checkout_venv_and_defaults():
    ...
```

**Step 2: Run test to verify it fails**

Run: `uv run pytest tests/test_setup_omlx.py -v`
Expected: FAIL because `scripts/setup_omlx.sh` does not exist yet.

**Step 3: Write minimal implementation**

Create the script after observing the failure.

**Step 4: Run test to verify it passes**

Run: `uv run pytest tests/test_setup_omlx.py -v`
Expected: PASS

### Task 2: Implement bootstrap script

**Files:**
- Create: `scripts/setup_omlx.sh`
- Modify: `README.md`
- Test: `tests/test_setup_omlx.py`

**Step 1: Write the failing test**

```python
def test_setup_omlx_updates_existing_checkout_without_reclone():
    ...
```

**Step 2: Run test to verify it fails**

Run: `uv run pytest tests/test_setup_omlx.py -v`
Expected: FAIL because the script does not yet handle the rerun case.

**Step 3: Write minimal implementation**

Implement:
- configurable checkout and venv paths
- clone-or-pull behavior
- `uv venv`
- editable install
- config/model directory preparation
- final executable validation

**Step 4: Run test to verify it passes**

Run: `uv run pytest tests/test_setup_omlx.py -v`
Expected: PASS

### Task 3: Regression verification

**Files:**
- Modify: `README.md`
- Test: `tests/test_setup_omlx.py`
- Test: `tests/test_start_omlx.py`

**Step 1: Run focused regression tests**

Run: `uv run pytest tests/test_setup_omlx.py tests/test_start_omlx.py -v`
Expected: PASS

**Step 2: Run full test suite**

Run: `uv run pytest`
Expected: PASS
