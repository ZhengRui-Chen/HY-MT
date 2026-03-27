from __future__ import annotations

import os
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SETUP_SCRIPT = ROOT / "scripts" / "setup_omlx.sh"
EXAMPLE_ENV = ROOT / "configs" / "omlx.env.example"


def write_tool(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8")
    path.chmod(0o755)


def make_fake_tools(bin_dir: Path, log_file: Path) -> None:
    write_tool(
        bin_dir / "git",
        f"""#!/bin/sh
echo "git:$@" >> "{log_file}"
if [ "$1" = "clone" ]; then
  mkdir -p "$3/.git"
  exit 0
fi
if [ "$1" = "-C" ] && [ "$3" = "pull" ]; then
  mkdir -p "$2/.git"
  exit 0
fi
exit 1
""",
    )
    write_tool(
        bin_dir / "uv",
        f"""#!/bin/sh
echo "uv:$@" >> "{log_file}"
if [ "$1" = "venv" ]; then
  mkdir -p "$2/bin"
  cat > "$2/bin/python" <<'EOF'
#!/bin/sh
exit 0
EOF
  chmod +x "$2/bin/python"
  exit 0
fi
if [ "$1" = "pip" ] && [ "$2" = "install" ] && [ "$3" = "--python" ]; then
  BIN_DIR=$(dirname "$4")
  cat > "$BIN_DIR/omlx" <<'EOF'
#!/bin/sh
exit 0
EOF
  chmod +x "$BIN_DIR/omlx"
  exit 0
fi
exit 1
""",
    )


def run_setup_script(*, tmp_path: Path, source_exists: bool) -> subprocess.CompletedProcess[str]:
    fake_bin = tmp_path / "fake-bin"
    fake_bin.mkdir()
    log_file = tmp_path / "calls.log"
    make_fake_tools(fake_bin, log_file)

    source_dir = tmp_path / "source"
    if source_exists:
        (source_dir / ".git").mkdir(parents=True)

    config_file = tmp_path / "configs" / "omlx.env"
    model_dir = tmp_path / "models"
    venv_dir = tmp_path / "venv-omlx"

    env = os.environ.copy()
    env.update(
        {
            "PATH": f"{fake_bin}:/usr/bin:/bin:/usr/sbin:/sbin",
            "OMLX_REPO_URL": "https://example.com/omlx.git",
            "OMLX_SOURCE_DIR": str(source_dir),
            "OMLX_VENV_DIR": str(venv_dir),
            "OMLX_CONFIG_FILE": str(config_file),
            "OMLX_MODEL_DIR": str(model_dir),
        }
    )
    return subprocess.run(
        ["zsh", str(SETUP_SCRIPT)],
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )


def test_setup_omlx_bootstraps_checkout_venv_and_defaults(tmp_path: Path) -> None:
    result = run_setup_script(tmp_path=tmp_path, source_exists=False)

    assert result.returncode == 0
    assert (tmp_path / "source" / ".git").is_dir()
    assert (tmp_path / "venv-omlx" / "bin" / "omlx").is_file()
    assert (tmp_path / "configs" / "omlx.env").read_text(encoding="utf-8") == EXAMPLE_ENV.read_text(
        encoding="utf-8"
    )
    assert (tmp_path / "models").is_dir()
    log_text = (tmp_path / "calls.log").read_text(encoding="utf-8")
    assert "git:clone https://example.com/omlx.git" in log_text
    assert "uv:venv" in log_text
    assert "uv:pip install --python" in log_text


def test_setup_omlx_updates_existing_checkout_without_reclone(tmp_path: Path) -> None:
    result = run_setup_script(tmp_path=tmp_path, source_exists=True)

    assert result.returncode == 0
    log_text = (tmp_path / "calls.log").read_text(encoding="utf-8")
    assert "git:clone" not in log_text
    assert f"git:-C {tmp_path / 'source'} pull --ff-only" in log_text
