# devcontainer - 设计方案（feat-env-upgrade-make-build-tags）

## 1. 设计目标与边界
- 精简组件：移除 kubectl、hexctl、Neovim 与其配置/插件；提供 Node.js 24 LTS 支持（最新小版本）。
- 基础镜像：TencentOS 变体切换为 `tencentos/tencentos4-minimal`；Debian 仍保留。
- 语言与工具链：满足 Python 3.11+、Go 1.25+、C++17+、Node.js 24 LTS。镜像内包含 `make` 工具。
- 标签规范：按“系统+单语言”方式生成独立标签（例如：`debian-go1.25.3`、`debian-node24.x.y`）。
- 构建入口：使用 `make` 统一构建，支持平台选择；默认使用当前平台；支持一次性多平台构建（buildx）。
- 保持简洁：遵循 `/specsai/constitution.md` 的日志与错误处理约定，不额外引入非必要组件。

## 2. 技术选型
- 基础镜像：
  - Debian 变体：延续 `debian` 官方镜像（稳定渠道），通过 apt 获取编译链与 Python（必要时加上 deadsnakes 或 pyenv 但仅在仓库源满足不了 3.11+ 的情况下才考虑）。
  - TencentOS 变体：`tencentos/tencentos4-minimal`，使用 `yum`/`dnf` 获取基础开发包。
- 工具链安装：
  - Python：要求精确到小版本。优先多阶段构建方案：在 builder 阶段从 python.org 源码精确版本编译（如 `3.11.7`），并将编译产物拷贝到最终镜像；若平台仓库恰好提供目标小版本且满足需求，可直接使用系统包以缩短构建时间。
  - Go：优先官方 tarball（/usr/local/go）；确保 `PATH` 包含 `/usr/local/go/bin`。
  - C++：使用系统 GCC/G++，并验证支持 `-std=c++17` 编译。
  - Node.js：要求 24 LTS 且精确到小版本。优先采用官方二进制（dist.tar.xz）方式安装；Debian 可选官方 LTS 源；TencentOS 推荐官方二进制以确保版本一致。
- 构建工具：Docker/Buildx；Make 作为唯一入口。
- 质量与规范：遵循仓库 `/.github/rules/*.md`，Shell 使用 `shfmt` 风格（不强制安装在镜像内）。

## 2.1 推荐做法（Best Practices）
- 版本收敛：通过 `ARG GO_VERSION`、`ARG PY_VERSION` 精确到小版本，并在构建时用于安装与打标签，保证镜像内容与标签一致。
- Node.js 版本：通过 `ARG NODE_VERSION` 设定 24 LTS 的最新小版本；下载官方二进制并可选校验哈希；失败即中止。
- 多阶段构建：Python 使用 builder 阶段编译，最终镜像仅包含运行所需产物，减小体积。
- 上游校验：下载 Go tarball 与 Python 源码时校验哈希（可选）并校正权限；失败即中止构建。
- 分层与缓存：将变更频率高的步骤（如复制文件）尽量后置；apt/yum 安装与清理放在同一层。
- .dockerignore：添加常规忽略（如 `.git/`、`specsai/`、临时文件）以缩小构建上下文。
- 元数据：添加规范的 OCI Labels（title、description、revision、created、licenses）。
- 运行用户：保持 root 以满足开发容器场景权限需求；如需 rootless，后续可新增可选变体，不在本次范围强制。

## 3. Dockerfile 结构设计
通用分层（两变体尽量对齐）：
1) 基础系统与环境变量
   - `ARG`：`GO_VERSION_MIN`、`PYTHON_VERSION_MIN`（用于注释/标签，不强制下载指定小版本）。
   - `ENV`：`PATH` 追加 `/usr/local/go/bin` 等。
2) 系统依赖与开发工具
   - 包含：`make`、`gcc/g++`、`python3(>=3.11)`、`python3-pip`、`cmake`、`git`、`zsh`、`tmux` 等。
   - 删除：kubectl、hexctl、neovim 相关安装与配置。
3) Go 安装（如系统仓库不满足 1.25+）
   - 采用官方 tarball 安装到 `/usr/local/go`，设置权限与 PATH。
4) 清理缓存
   - Debian：`rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*`
   - TencentOS：`rm -rf /var/cache/yum` 或 `dnf clean all`
5) 元数据
   - OCI Labels：`org.opencontainers.image.title`、`description`、`revision`、`created` 等。

注意：
- 构建步骤使用 `&&` 串联；下载后进行最小化校验与权限设置；严格清理缓存以优化体积。
- 不默认添加非必要的语言管理器（如 pyenv），仅在平台仓库不满足最低版本时才作为备选实现。

## 4. 语言与版本策略
- Python：目标为 `>=3.11` 且精确到小版本（始终采用“最新小版本”策略，如 `3.11.7`）；通过多阶段构建从源码编译并复制产物，或在可用时使用系统仓库的相同小版本；在构建产物中写入 `org.opencontainers.image.version.python` 标签。
- Go：目标为 `>=1.25` 且精确到小版本（始终采用“最新小版本”策略，如 `1.25.3`）；使用官方 tarball；在镜像中写入 `org.opencontainers.image.version.go` 标签。
- Node.js：目标为 `24 LTS` 且精确到小版本（采用“最新小版本”策略，如 `24.x.y`）；安装完成后写入 `org.opencontainers.image.version.node` 标签。
- C++：以系统 GCC/G++ 为主，验证 `-std=c++17` 可用（通过简单编译测试在 README 中示例展示）。

## 5. 镜像标签规范
- 基本格式：`<repo>:<os>-<lang><version>`（单语言维度标签）
  - `<os>`：`debian` 或 `tencentos4`。
  - `<lang>`：`go`、`py`、`node`、`cpp`（C++ 用标准位 `cpp17` 表示能力，不含小版本）。
  - `<version>`：语言精确到小版本（如 `go1.25.3`、`py3.11.7`、`node24.x.y`；C++ 标记为 `cpp17`）。
- 生成策略：
  - 同一镜像可打出多个“系统+单语言”标签，分别对应已安装语言及其版本；例如：
    - `fize/devcontainer:debian-go1.25.3`
    - `fize/devcontainer:debian-py3.11.7`
    - `fize/devcontainer:debian-node24.x.y`
    - `fize/devcontainer:debian-cpp17`
  - TencentOS 变体示例：
    - `fize/devcontainer:tencentos4-go1.25.3`
    - `fize/devcontainer:tencentos4-py3.11.7`
    - `fize/devcontainer:tencentos4-node24.x.y`
    - `fize/devcontainer:tencentos4-cpp17`
- 附加策略：可追加 `-<date>` 或 `-<gitsha>`（可选）以增强可追踪性。

## 6. Make 构建编排设计
- 变量：
  - `OS`：`debian`/`tencentos4`（默认：`debian`）。
  - `PLATFORM`：Docker 目标平台，如 `linux/amd64`、`linux/arm64`；默认留空表示使用当前平台。
  - `REPO`：仓库名，默认 `fize/devcontainer`（或从 `IMAGE_REPO` 环境变量读取）。
  - `GO_VER`、`PY_VER`、`NODE_VER`：精确到小版本（如 `1.25.3`、`3.11.7`、`24.x.y`），用于生成标签并以 `--build-arg` 传入 Dockerfile；C++ 固定为 `cpp17` 能力标识。
  - `TAG_EXTRA`：附加标识，如日期或 `-dev`。
- 目标：
  - `build`：根据 `OS` 选择 Dockerfile；当 `PLATFORM` 非空时使用 `docker buildx build --platform=$(PLATFORM)`，否则使用 `docker build`。
  - `tag`：依据 `GO_VER`/`PY_VER`/`NODE_VER` 生成“系统+单语言”多个标签并 `docker tag`。
  - `inspect-labels`（可选）：`docker inspect` 读取镜像的 `org.opencontainers.image.version.*` 标签，与 Make 变量对比，若不一致则失败，确保标签与内容一致性。
  - `push`：按需推送；当 `PLATFORM` 非空且需要多架构产物时建议使用 `--push`。
  - `build-multi`：一次性多平台构建；使用 `docker buildx build --platform=$(PLATFORMS) --push`（需要 buildx 与 registry）。
  - `run`：以交互模式运行镜像，默认 `/bin/zsh`。
- 默认平台策略：
  - 若未显式设置 `PLATFORM`，不传 `--platform`，遵循 Docker 默认（当前主机平台）。
  - 若设置了 `PLATFORM`，优先要求用户配置 `buildx`（文档中给出初始化指引）。
 - 多平台变量：
  - `PLATFORMS`：多平台逗号分隔列表，默认 `linux/amd64,linux/arm64`；供 `build-multi` 使用。
  - 说明：Docker 镜像的 OS 平台为容器运行时（Linux）。在 macOS Apple Silicon 上，Docker Desktop 运行 `linux/arm64` 镜像；不存在 `darwin/arm64` 镜像平台。

## 7. 日志与错误处理（遵循规约）
- 日志：构建阶段依赖 Docker 控制台输出；容器应用通过 stdout/stderr 输出，不落磁盘。
- 错误处理：
  - Dockerfile 中通过 `&&` 串联命令，任一步失败即中止。
  - 脚本中建议 `set -euo pipefail`；对下载结果进行基本校验（大小/哈希可选）。
  - 构建结束清理包管理缓存与临时文件，保证可重复构建。

## 8. 验证与回归
- 构建验证：
  - `make build OS=debian` 与 `make build OS=tencentos4` 能成功完成。
  - 不安装 kubectl/hexctl/neovim；`make --version` 在容器中可用。
  - `python3 --version >= 3.11`、`go version >= 1.25`、`node --version` 为 24.x 最新小版本、`g++ -std=c++17` 能编译简单程序。
  - 标签一致性：`make inspect-labels` 断言镜像内的版本标签与外部传入版本一致。
- 跨平台验证：
  - 未设置 `PLATFORM` 时在本机平台构建成功。
  - 设置 `PLATFORM=linux/amd64` 或 `linux/arm64` 时，使用 buildx 构建成功（需本地已配置 buildx）。
  - `make build-multi PLATFORMS=linux/amd64,linux/arm64` 一次性构建并推送多平台产物成功。
  - macOS (Apple Silicon)：通过 Docker Desktop 拉起并运行 `linux/arm64` 平台镜像验证成功。

## 9. 风险与缓解
- 平台仓库的 Python 版本不足：保留官方二进制/pyenv 作为降级策略；文档说明差异化步骤。
- 多架构构建环境差异：文档中提供 buildx 初始化指南与常见问题。
- 标签一致性：在 Make 统一生成，避免手写错误。

## 10. 开放问题（请确认）
- 默认用于标签的小版本：请确认 `GO_VER` 与 `PY_VER` 的默认小版本（例如 `go1.25.3`、`py3.11.7`）。
- 单镜像是否总是同时打出多条“系统+单语言”标签（推荐），或按需只打主要语言标签？
