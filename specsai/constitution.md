```markdown
# devcontainer - 规约

## 技术栈

### 主要依赖
- Go - 1.25.3
- Python - 3.13.1
- Node.js - 24.11.1
- C++ (GCC) - C++17
- Docker / Docker Buildx - 用于镜像构建和多平台打包
- TencentOS 4 Minimal - 作为镜像基础（`tencentos/tencentos4-minimal`）

### 开发工具
- 依赖管理 - 通过 `Dockerfile-*` 与 `Makefile` 管理运行时/构建时依赖与版本（`GO_VER`, `PY_VER`, `NODE_VER`, `CPP_VER` 等）。
- 构建工具 - `make` + `docker buildx`（`Makefile` 提供统一入口与多平台选项）。
- 测试框架 - 仓库未使用传统语言层面的测试框架；提供镜像验证目标 `make validate`，通过在容器中运行版本/简单命令做快速校验。
- 代码质量工具 - 仓库当前未配置统一的静态检查或格式化工具；建议在各语言具体项目中启用 `golangci-lint` / `pylint` / `eslint` / `clang-tidy` 等。

## 项目开发要求

### 日志
- 容器运行时的日志应输出到 `stdout` / `stderr`（遵循 12-factor app 原则），容器不应依赖写入主机上的持久日志路径。
- 构建阶段的日志由 Docker 输出，遇到构建错误应及时查看并修复。

### 错误处理
- Dockerfile 与 `Makefile` 在构建中使用 `&&` 链式命令以保证命令失败时构建即时中止（项目 README 明确说明此做法）。
- 所有 Makefile 目标与自动化脚本应在失败时返回非零退出码，便于 CI/自动化系统判定构建失败。
- 对外部下载的二进制或源码应在构建过程中验证完整性（例如使用 SHA256 校验和），若校验失败应中止构建流程（README 中提及对下载文件做校验的做法）。

```# devcontainer - 规约

## 技术栈

### 主要依赖
- 核心语言 - Dockerfile 与 Shell（随 Docker/基础镜像版本）
- 核心框架依赖 - 无应用框架，容器镜像构建为核心
- 其他组件依赖 - Go 1.25.3；Python 3.13.1；Node.js 24.11.1；GCC/G++ C++17（系统）

### 开发工具
- 依赖管理 - TencentOS 4 使用 dnf（使用 `--setopt=install_weak_deps=False` 最小化安装）
- 构建工具 - Docker Buildx（镜像构建与多平台打包）；Make（构建自动化）
- 测试框架 - 无（当前仓库不包含测试，使用 `make validate` 进行镜像功能验证）
- 代码质量工具 - shfmt（Shell/格式化）；并遵循仓库 `/.github/rules/*.md` 语言规范

## 项目开发要求

### 日志
- 容器内应用应通过 stdout/stderr 输出日志；镜像构建阶段依赖 Docker 构建日志；不得在镜像中写入持久日志文件；避免输出敏感信息。

### 错误处理
- 在 Dockerfile 中使用 `&&` 串联命令并在失败时中断；对下载产物进行校验和验证（SHA256/MD5）；安装完成后清理包管理缓存（`dnf clean all && rm -rf /var/cache/dnf/*`）与临时文件以保证可重复构建并便于定位错误。