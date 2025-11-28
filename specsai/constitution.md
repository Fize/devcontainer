# devcontainer - 规约

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