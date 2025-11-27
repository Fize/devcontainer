# devcontainer

## 核心功能模块

### 1. Debian 开发环境
- **功能描述**: 提供基于 Debian 的全功能开发环境，集成多种编程语言和开发工具。
- **关键技术特性**:
    - 基于 `debian:rc-buggy` 镜像。
    - 集成 Node.js 20, Go 1.22.0, Python 3, C/C++ 编译环境。
    - 预装 Neovim 编辑器及个性化配置。
    - 集成 Kubernetes 管理工具 (kubectl, hexctl)。
- **与其他模块的交互**: 独立构建，可作为 VS Code Dev Container 使用。

### 2. TencentOS 开发环境
- **功能描述**: 提供基于 TencentOS 的开发环境，适配腾讯云生态或特定服务器环境。
- **关键技术特性**:
    - 基于 `tencentos/tencentos_server31_mini:20240220` 镜像。
    - 集成 Go 1.22.0, Python 3, C/C++ 编译环境。
    - 集成 Kubernetes 管理工具 (kubectl, hexctl)。
- **与其他模块的交互**: 独立构建。

## 项目结构分析

### 入口文件
- `Dockerfile-debian` - Debian 环境构建定义文件。
- `Dockerfile-tencentos` - TencentOS 环境构建定义文件。

### 核心业务包
- 本项目为 Docker 镜像构建项目，无传统业务包结构。核心逻辑在于 Dockerfile 中的指令序列。

### 基础设施包
- 无独立基础设施代码，依赖 Docker 引擎和基础镜像源 (Debian, TencentOS)。

### 代码目录文件结构

- `/`
  - `Dockerfile-debian`: Debian 开发环境构建文件
  - `Dockerfile-tencentos`: TencentOS 开发环境构建文件
  - `README.md`: 项目说明文档
  - `LICENSE`: 许可证文件

## 技术栈

### 主要依赖
- **Docker** - 容器化平台
- **Debian** - 基础操作系统 (rc-buggy)
- **TencentOS** - 基础操作系统 (Server 3.1 Mini)

### 开发工具
- **Go** - 1.22.0
- **Node.js** - 20 (Debian only)
- **Python** - 3
- **C/C++** - GCC/G++
- **Neovim** - 编辑器 (Debian only)
- **kubectl** - v1.29.2 (Kubernetes CLI)
- **hexctl** - V0.1.7 (Custom CLI)
- **zsh/tmux** - 终端效率工具

## 开发和使用指南

### 环境配置
```bash
# 依赖安装命令
# 需要安装 Docker Desktop 或 Docker Engine
```

### 构建和运行
```bash
# 构建 Debian 镜像
docker build -f Dockerfile-debian -t devcontainer-debian .

# 构建 TencentOS 镜像
docker build -f Dockerfile-tencentos -t devcontainer-tencentos .

# 运行容器
docker run -it devcontainer-debian /bin/zsh
```

## 项目架构特点

### 设计模式
- **Infrastructure as Code (IaC)**: 使用 Dockerfile 定义开发环境基础设施。

### 数据流设计
- 不涉及运行时数据流，主要为构建时镜像层构建流。

### 错误处理
- 依赖 Docker 构建过程中的错误反馈机制。

## 安全考虑
- **基础镜像安全**: 使用官方或特定版本的 OS 镜像。
- **权限管理**: 容器内默认使用 root 用户 (Dockerfile 中未见用户切换)。

## 性能优化
- **层缓存**: 利用 Docker 镜像分层机制加速构建。
- **清理缓存**: 在 RUN 指令中清理 apt/yum 缓存以减小镜像体积。

## 扩展性设计
- **多架构支持**: 通过不同的 Dockerfile 支持不同的基础 OS。

## 部署和运维
- **部署环境要求**: 支持 Docker 的任何操作系统。
