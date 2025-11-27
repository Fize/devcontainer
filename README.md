# Devcontainer

Development containers for VS Code with support for multiple programming languages and platforms.

## Features

- **Multiple OS Variants**: Debian and TencentOS 4
- **Language Support**:
  - Go 1.23.4+
  - Python 3.13.1+
  - Node.js 24.12.0 LTS
  - C++17
- **Multi-platform**: linux/amd64, linux/arm64 (including macOS Apple Silicon via Docker Desktop)
- **Unified Build System**: Makefile-based automation
- **Language-specific Tags**: Easy identification with `<os>-<lang><version>` format

## Quick Start

### Prerequisites

- Docker Desktop or Docker Engine
- For multi-platform builds: Docker Buildx (included in Docker Desktop)

### Build Single Platform

```bash
# Build Debian variant (default)
make build

# Build TencentOS variant
make build OS=tencentos4

# Build for specific platform
make build PLATFORM=linux/arm64
```

### Build Multi-Platform

```bash
# Build and push for both amd64 and arm64
make build-multi OS=debian

# Custom platforms
make build-multi PLATFORMS=linux/amd64,linux/arm64
```

### Create Language Tags

```bash
# Tag with all language versions
make tag OS=debian

# Tags created:
#   fize/devcontainer:debian-go1.23.4
#   fize/devcontainer:debian-py3.13.1
#   fize/devcontainer:debian-node24.12.0
#   fize/devcontainer:debian-cpp17
```

### Run Container

```bash
# Run interactively
make run OS=debian

# Or directly with Docker
docker run --rm -it devcontainer-debian /bin/zsh
```

## Image Tag Naming

Images follow the pattern: `<repo>:<os>-<lang><version>`

- `<os>`: `debian` or `tencentos4`
- `<lang>`: `go`, `py`, `node`, or `cpp17`
- `<version>`: Exact version (e.g., `1.23.4`) or capability (e.g., `cpp17`)

Examples:
- `fize/devcontainer:debian-go1.23.4`
- `fize/devcontainer:debian-py3.13.1`
- `fize/devcontainer:debian-node24.12.0`
- `fize/devcontainer:tencentos4-cpp17`

## Makefile Targets

| Target | Description |
|--------|-------------|
| `build` | Build single-platform image |
| `build-multi` | Build and push multi-platform images |
| `tag` | Create language-specific tags |
| `inspect-labels` | Verify OCI label consistency |
| `push` | Push tagged images to registry |
| `run` | Run container interactively |
| `clean` | Remove built images |
| `help` | Show usage information |

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OS` | `debian` | Target OS (debian or tencentos4) |
| `PLATFORM` | (empty) | Single platform (e.g., linux/arm64) |
| `PLATFORMS` | `linux/amd64,linux/arm64` | Multi-platform list |
| `REPO` | `fize/devcontainer` | Docker repository name |
| `GO_VER` | `1.23.4` | Go version |
| `PY_VER` | `3.13.1` | Python version |
| `NODE_VER` | `24.12.0` | Node.js version |
| `TAG_EXTRA` | (empty) | Additional tag suffix |

## Platform Support

### Native Platforms
- `linux/amd64` - x86-64 architecture
- `linux/arm64` - ARM64 architecture

### macOS Apple Silicon
Docker containers run Linux images on macOS. For Apple Silicon Macs:
- Docker Desktop automatically runs `linux/arm64` images
- No special configuration needed
- Images use Linux binaries, not `darwin/arm64`

## Verification

### Verify C++17 Support

```bash
docker run --rm devcontainer-debian bash -c \
  'echo "int main(){}" | g++ -std=c++17 -x c++ - && echo "C++17 OK"'

docker run --rm devcontainer-tencentos4 bash -c \
  'echo "int main(){}" | g++ -std=c++17 -x c++ - && echo "C++17 OK"'
```

### Verify Language Versions

```bash
# Debian
docker run --rm devcontainer-debian python3 --version
docker run --rm devcontainer-debian go version
docker run --rm devcontainer-debian node --version
docker run --rm devcontainer-debian g++ --version

# TencentOS
docker run --rm devcontainer-tencentos4 python3 --version
docker run --rm devcontainer-tencentos4 go version
docker run --rm devcontainer-tencentos4 node --version
docker run --rm devcontainer-tencentos4 g++ --version
```

### Verify Label Consistency

```bash
make inspect-labels OS=debian
make inspect-labels OS=tencentos4
```

## Examples

### Build Custom Version

```bash
make build OS=debian GO_VER=1.23.5 PY_VER=3.13.2
make tag OS=debian GO_VER=1.23.5 PY_VER=3.13.2
```

### Build and Push

```bash
# Build, tag, and push
make build OS=debian
make tag OS=debian
make push OS=debian

# Or combine with multi-platform
make build-multi OS=debian
```

### Use Specific Language Tag

```bash
# Pull and run Go-focused image
docker pull fize/devcontainer:debian-go1.23.4
docker run --rm -it fize/devcontainer:debian-go1.23.4 go version

# Pull and run Node.js-focused image
docker pull fize/devcontainer:debian-node24.12.0
docker run --rm -it fize/devcontainer:debian-node24.12.0 node --version
```

## Development

The project follows these principles:
- **Minimal Images**: Only essential development tools
- **Caching-Friendly**: Optimized layer structure
- **Version Consistency**: OCI labels match actual versions
- **Error Handling**: Fail-fast with `&&` command chaining

## License

See [LICENSE](LICENSE) file.