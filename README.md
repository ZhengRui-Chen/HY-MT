# HY-MT

HY-MT 是从 `glint` 中拆分出来的独立后端仓库，用来收容本地模型部署、
`oMLX` 服务启动、LaunchAgent 运维脚本，以及命令行 smoke test。

`glint` 现在只负责 macOS 客户端交互；如果你要准备本地翻译后端，请在这个仓库里完成。

相关仓库：

- macOS 客户端：`https://github.com/ZhengRui-Chen/glint`
- 当前后端栈：`oMLX` + `HY-MT`

## 仓库内容

- `src/hy_mt_deploy/`: Python 工具代码
- `scripts/`: 启停、状态、smoke test、LaunchAgent 脚本
- `configs/omlx.env.example`: 本地配置模板
- `launchd/`: macOS LaunchAgent 模板
- `tests/`: 单元测试

## 快速开始

1. 安装依赖：

```bash
uv sync
```

2. 安装 `oMLX` 可执行文件：

```bash
zsh scripts/setup_omlx.sh
```

这个脚本会：

- 拉取或更新 `jundot/omlx` 源码到 `.runtime/omlx/source`
- 用 `uv` 创建 `.venv-omlx`
- 把 `omlx` 安装到 `.venv-omlx/bin/omlx`
- 在缺失时生成 `configs/omlx.env`
- 创建默认的 `models/` 目录

如果你把 `omlx` 装在了非默认位置，启动前也可以手动指定：

```bash
export OMLX_BIN=/path/to/omlx
```

3. 准备模型：

如果本机原来把模型放在 `../glint/models`，直接迁移：

```bash
mkdir -p models
mv ../glint/models/HY-MT1.5-1.8B-4bit models/
```

如果是新机器，直接下载到当前仓库：

```bash
zsh scripts/download_model.sh
```

默认会下载 `mlx-community/HY-MT1.5-1.8B-4bit` 到 `models/HY-MT1.5-1.8B-4bit`。

4. 准备本地配置：

```bash
cp configs/omlx.env.example configs/omlx.env
```

5. 启动服务：

```bash
zsh scripts/start_omlx_tmux.sh
```

6. 检查状态：

```bash
zsh scripts/status_omlx.sh
```

## 常用命令

直接启动：

```bash
zsh scripts/start_omlx.sh
```

停止服务：

```bash
zsh scripts/stop_omlx.sh
```

重启服务：

```bash
zsh scripts/restart_omlx.sh
```

查看状态：

```bash
zsh scripts/status_omlx.sh
```

命令行 smoke test：

```bash
uv run python scripts/smoke_cli.py \
  --model-id ./models/HY-MT1.5-1.8B-4bit \
  --text "It is a pleasure to meet you." \
  --target-language 中文 \
  --max-tokens 64
```

OpenAI-compatible API smoke test：

```bash
python3 scripts/api_smoke.py
```

## LaunchAgent

安装 `oMLX` 服务 LaunchAgent：

```bash
zsh scripts/install_omlx_launch_agent.sh
zsh scripts/start_omlx_launch_agent.sh
zsh scripts/status_omlx_launch_agent.sh
```

安装定时重启检查的 LaunchAgent：

```bash
zsh scripts/install_launch_agent.sh
```

## 默认约定

- API 地址：`http://127.0.0.1:8001`
- OpenAI-compatible 路径：
  - `GET /v1/models`
  - `POST /v1/chat/completions`
- 默认模型目录：`models/HY-MT1.5-1.8B-4bit`
- 默认环境文件：`configs/omlx.env`

## 上游链接

- oMLX: `https://github.com/jundot/omlx`
- Tencent HY-MT: `https://github.com/Tencent-Hunyuan/HY-MT`
- MLX 社区量化模型：`https://huggingface.co/mlx-community/HY-MT1.5-1.8B-4bit`
