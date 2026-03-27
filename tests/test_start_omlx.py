from __future__ import annotations

import os
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
START_SCRIPT = ROOT / "scripts" / "start_omlx.sh"


def run_start_script(env_overrides: dict[str, str]) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env.update(env_overrides)
    env["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin"
    return subprocess.run(
        ["zsh", str(START_SCRIPT)],
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )


def test_start_omlx_reports_missing_binary_with_actionable_message() -> None:
    result = run_start_script({"OMLX_BIN": "/tmp/definitely-missing-omlx"})

    assert result.returncode == 1
    assert "oMLX binary not found" in result.stderr
    assert "/tmp/definitely-missing-omlx" in result.stderr
    assert "OMLX_BIN" in result.stderr


def test_start_omlx_uses_explicit_omlx_bin_override(tmp_path: Path) -> None:
    fake_omlx = tmp_path / "omlx"
    fake_omlx.write_text(
        "#!/bin/sh\n"
        "printf '%s\n' \"$0\" \"$@\"\n",
        encoding="utf-8",
    )
    fake_omlx.chmod(0o755)

    result = run_start_script({"OMLX_BIN": str(fake_omlx)})

    assert result.returncode == 0
    stdout_lines = result.stdout.splitlines()
    assert stdout_lines[0] == str(fake_omlx)
    assert stdout_lines[1] == "serve"
