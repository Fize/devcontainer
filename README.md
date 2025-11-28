# Devcontainer

基于 TencentOS 4 的 VS Code 开发容器，按编程语言独立分离。

## 特性

- **基于 TencentOS 4 Minimal**：轻量级、容器优化的 RHEL 兼容系统
- **语言独立镜像**：每种语言独立的 Dockerfile，最小化依赖
  - Go 1.25.3
  - Python 3.13.1（源码编译，启用优化）
  - Node.js 24.11.1 LTS
  - C++17 (GCC)
- **多平台支持**：linux/amd64, linux/arm64（支持 macOS Apple Silicon）
- **dnf 包管理**：使用 `--setopt=install_weak_deps=False` 最小化安装
- **VS Code DevContainer 兼容**：提供即用的配置文件

## 快速开始

### 前置条件

- Docker Desktop 或 Docker Engine
- 多平台构建需要 Docker Buildx（Docker Desktop 已内置）

### 构建镜像

```bash
# 构建 Go 镜像
make build LANG=go

# 构建 Python 镜像
make build LANG=python

# 构建 Node.js 镜像
make build LANG=node

# 构建 C++ 镜像
make build LANG=cpp

# 构建所有语言镜像
make build-all
```

### 多平台构建

```bash
# 构建并推送多平台镜像
make build-multi LANG=go

# 自定义平台
make build-multi LANG=python PLATFORMS=linux/amd64,linux/arm64
```

### 运行容器

```bash
# 交互式运行
make run LANG=go

# 或直接使用 Docker
docker run --rm -it devcontainer-go:local /bin/bash
```

### 验证构建

```bash
# 快速验证
make validate LANG=go
make validate LANG=python
make validate LANG=node
make validate LANG=cpp
```

## 镜像标签命名

镜像标签格式：`<repo>:<lang><version>`

- `<lang>`：`go`, `py`, `node`, `cpp`
- `<version>`：具体版本号

示例：
- `malzaharguo/devcontainer:go1.25.3`
- `malzaharguo/devcontainer:py3.13.1`
- `malzaharguo/devcontainer:node24.11.1`
- `malzaharguo/devcontainer:cpp17`

## DevContainer 使用

项目提供 4 套 VS Code DevContainer 配置，位于 `.devcontainer/` 目录：

```
.devcontainer/
├── go/devcontainer.json       # Go 开发环境
├── python/devcontainer.json   # Python 开发环境
├── node/devcontainer.json     # Node.js 开发环境
└── cpp/devcontainer.json      # C++ 开发环境
```

### 使用方法

1. 将对应语言的 `devcontainer.json` 复制到你的项目
2. 在 VS Code 中打开项目
3. 使用 "Reopen in Container" 命令

### Go DevContainer 示例

```jsonc
{
  "name": "Go Development Container",
  "image": "malzaharguo/devcontainer:go1.25.3",
  "customizations": {
    "vscode": {
      "extensions": ["golang.go"],
      "settings": {
        "go.useLanguageServer": true
      }
    }
  },
  "workspaceFolder": "/workspace",
  "postCreateCommand": "go version"
}
```

## Makefile 目标

| 目标 | 描述 |
|------|------|
| `build` | 构建单平台镜像 |
| `build-multi` | 构建并推送多平台镜像 |
| `push` | 推送镜像到仓库 |
| `run` | 交互式运行容器 |
| `validate` | 快速验证测试 |
| `clean` | 清理构建的镜像 |
| `build-all` | 构建所有语言镜像 |
| `push-all` | 推送所有语言镜像 |
| `help` | 显示帮助信息 |

## 配置变量

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `LANG` | `go` | 目标语言 (go, python, node, cpp) |
| `GO_VER` | `1.25.3` | Go 版本 |
| `PY_VER` | `3.13.1` | Python 版本 |
| `NODE_VER` | `24.11.1` | Node.js 版本 |
| `CPP_VER` | `17` | C++ 标准版本 |
| `PLATFORM` | (空) | 单平台 (如 linux/arm64) |
| `PLATFORMS` | `linux/amd64,linux/arm64` | 多平台列表 |
| `REPO` | `malzaharguo/devcontainer` | Docker 仓库名称 |

## 平台支持

### 原生平台
- `linux/amd64` - x86-64 架构
- `linux/arm64` - ARM64 架构

### macOS Apple Silicon
- Docker Desktop 自动运行 `linux/arm64` 镜像
- 无需特殊配置
- 镜像使用 Linux 二进制文件

## 验证示例

### 验证 Go 环境

```bash
docker run --rm devcontainer-go:local go version
docker run --rm devcontainer-go:local go env GOPATH
docker run --rm devcontainer-go:local git --version
```

### 验证 Python 环境

```bash
docker run --rm devcontainer-python:local python3 --version
docker run --rm devcontainer-python:local pip3 --version
docker run --rm devcontainer-python:local python --version  # 软链接
```

### 验证 Node.js 环境

```bash
docker run --rm devcontainer-node:local node --version
docker run --rm devcontainer-node:local npm --version
```

### 验证 C++ 环境

```bash
docker run --rm devcontainer-cpp:local g++ --version
docker run --rm devcontainer-cpp:local bash -c \
  'echo "int main(){}" | g++ -std=c++17 -x c++ - && echo "C++17 OK"'
```

## 构建示例

### 构建自定义版本

```bash
make build LANG=go GO_VER=1.26.0
make build LANG=python PY_VER=3.14.0
```

### 构建并推送

```bash
# 单语言
make push LANG=go

# 所有语言
make push-all

# 多平台构建并推送
make build-multi LANG=go
```

## 项目结构

```
devcontainer/
├── Dockerfile-go          # Go 开发镜像
├── Dockerfile-python      # Python 开发镜像（多阶段构建）
├── Dockerfile-node        # Node.js 开发镜像
├── Dockerfile-cpp         # C++ 开发镜像
├── Makefile               # 统一构建入口
├── devcontainer/
│   ├── go/devcontainer.json
│   ├── python/devcontainer.json
│   ├── node/devcontainer.json
│   └── cpp/devcontainer.json
└── README.md
```

## 设计原则

- **最小化镜像**：仅包含必要的开发工具
- **缓存友好**：优化的层结构
- **版本一致性**：OCI 标签与实际版本匹配
- **错误处理**：使用 `&&` 命令链实现快速失败

## License

See [LICENSE](LICENSE) file.