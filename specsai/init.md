# devcontainer

## 核心功能模块

### 1. Go 开发环境 (Dockerfile-go)
- **功能描述**: 提供基于 TencentOS 4 的 Go 语言开发环境。
- **关键技术特性**:
    - 基于 `tencentos/tencentos4-minimal:4.4-v20251020` 镜像。
    - 集成 Go 1.25.3（官方预编译二进制）。
    - 使用 dnf 包管理器，最小化系统包。
    - 预装 git, curl, make 等基础工具。
- **与其他模块的交互**: 独立构建，可作为 VS Code DevContainer 使用。

### 2. Python 开发环境 (Dockerfile-python)
- **功能描述**: 提供基于 TencentOS 4 的 Python 开发环境。
- **关键技术特性**:
    - 基于 `tencentos/tencentos4-minimal:4.4-v20251020` 镜像。
    - 集成 Python 3.13.1（源码编译，启用优化）。
    - 多阶段构建，最小化最终镜像体积。
    - 预装 pip 包管理器和基础开发工具。
- **与其他模块的交互**: 独立构建。

### 3. Node.js 开发环境 (Dockerfile-node)
- **功能描述**: 提供基于 TencentOS 4 的 Node.js 开发环境。
- **关键技术特性**:
    - 基于 `tencentos/tencentos4-minimal:4.4-v20251020` 镜像。
    - 集成 Node.js 24.11.1 LTS（官方预编译二进制）。
    - 使用 dnf 包管理器，最小化系统包。
    - 预装 npm 包管理器和基础开发工具。
- **与其他模块的交互**: 独立构建。

### 4. C++ 开发环境 (Dockerfile-cpp)
- **功能描述**: 提供基于 TencentOS 4 的 C++ 开发环境。
- **关键技术特性**:
    - 基于 `tencentos/tencentos4-minimal:4.4-v20251020` 镜像。
    - 集成 GCC/G++ 支持 C++17 标准。
    - 使用 dnf 包管理器，最小化系统包。
    - 预装 cmake, make, git 等构建工具。
- **与其他模块的交互**: 独立构建。

## 项目结构分析

### 入口文件
- `Dockerfile-go` - Go 开发环境构建文件
- `Dockerfile-python` - Python 开发环境构建文件（多阶段构建）
- `Dockerfile-node` - Node.js 开发环境构建文件
- `Dockerfile-cpp` - C++ 开发环境构建文件
- `Makefile` - 统一构建入口，支持 LANG 参数选择语言

### 核心业务包
- 本项目为 Docker 镜像构建项目，无传统业务包结构。核心逻辑在于 Dockerfile 中的指令序列。

### 基础设施包
- 无独立基础设施代码，依赖 Docker 引擎和基础镜像源 (TencentOS 4)。

### 代码目录文件结构

- `/`
  - `Dockerfile-go`: Go 开发环境构建文件
  - `Dockerfile-python`: Python 开发环境构建文件
  - `Dockerfile-node`: Node.js 开发环境构建文件
  - `Dockerfile-cpp`: C++ 开发环境构建文件
  - `Makefile`: 统一构建入口
  - `README.md`: 项目说明文档
  - `LICENSE`: 许可证文件
  - `.devcontainer/`: VS Code DevContainer 配置目录
    - `go/devcontainer.json`: Go DevContainer 配置
    - `python/devcontainer.json`: Python DevContainer 配置
    - `node/devcontainer.json`: Node.js DevContainer 配置
    - `cpp/devcontainer.json`: C++ DevContainer 配置

## 技术栈

### 主要依赖
- **Docker** - 容器化平台
- **TencentOS 4 Minimal** - 基础操作系统 (tencentos/tencentos4-minimal:4.4-v20251020)
- **dnf** - 包管理器（使用 --setopt=install_weak_deps=False 最小化安装）

### 开发工具
- **Go** - 1.25.3
- **Python** - 3.13.1（源码编译，启用优化）
- **Node.js** - 24.11.1 LTS
- **C++** - GCC/G++ 支持 C++17
- **git** - 版本控制
- **make/cmake** - 构建工具

## 开发和使用指南

### 环境配置
```bash
# 需要安装 Docker Desktop 或 Docker Engine
# 多平台构建需要 Docker Buildx（Docker Desktop 已内置）
```

### 构建和运行
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

# 运行容器
make run LANG=go

# 或直接使用 Docker
docker run -it devcontainer-go:local /bin/bash
```

### 镜像标签命名
镜像标签格式：`<repo>:<lang><version>`

示例：
- `malzaharguo/devcontainer:go1.25.3`
- `malzaharguo/devcontainer:py3.13.1`
- `malzaharguo/devcontainer:node24.11.1`
- `malzaharguo/devcontainer:cpp17`

## 项目架构特点

### 设计模式
- **Infrastructure as Code (IaC)**: 使用 Dockerfile 定义开发环境基础设施。
- **语言分离**: 每种语言独立的 Dockerfile，最小化依赖。

### 数据流设计
- 不涉及运行时数据流，主要为构建时镜像层构建流。

### 错误处理
- 依赖 Docker 构建过程中的错误反馈机制。
- 使用 `&&` 命令链实现快速失败。

## 安全考虑
- **基础镜像安全**: 使用官方 TencentOS 4 Minimal 镜像。
- **权限管理**: 容器内默认使用 root 用户。
- **依赖验证**: 下载的二进制文件通过 SHA256 校验和验证。

## 性能优化
- **层缓存**: 利用 Docker 镜像分层机制加速构建。
- **清理缓存**: 在 RUN 指令中清理 dnf 缓存以减小镜像体积。
- **多阶段构建**: Python 镜像使用多阶段构建减小最终体积。
- **最小化依赖**: 使用 `--setopt=install_weak_deps=False` 避免安装不必要的包。

## 扩展性设计
- **多架构支持**: 支持 linux/amd64 和 linux/arm64 平台。
- **语言独立**: 每种语言独立镜像，便于单独升级和维护。

## 部署和运维
- **部署环境要求**: 支持 Docker 的任何操作系统。
- **VS Code DevContainer**: 提供即用的 DevContainer 配置文件。
