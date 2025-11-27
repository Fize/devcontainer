# devcontainer - 规约

## 技术栈

### 主要依赖
- 核心语言 - Dockerfile 与 Shell（随 Docker/基础镜像版本）
- 核心框架依赖 - 无应用框架，容器镜像构建为核心
- 其他组件依赖 - Go 1.22.0；Node.js 20.x（Debian）；Python 3.x；GCC/G++（系统）；Neovim；kubectl v1.29.2；hexctl V0.1.7

### 开发工具
- 依赖管理 - Debian 使用 apt；TencentOS 使用 yum
- 构建工具 - Docker（镜像构建与打包）
- 测试框架 - 无（当前仓库不包含测试）
- 代码质量工具 - shfmt（Shell/格式化）；并遵循仓库 `/.github/rules/*.md` 语言规范

## 项目开发要求

### 日志
- 容器内应用应通过 stdout/stderr 输出日志；镜像构建阶段依赖 Docker 构建日志；不得在镜像中写入持久日志文件；避免输出敏感信息。

### 错误处理
- 在 Dockerfile 中使用 `&&` 串联命令并在失败时中断；对下载产物进行权限/校验和等显式校验；在脚本中使用 `set -euo pipefail`；安装完成后清理包管理缓存与临时文件以保证可重复构建并便于定位错误。