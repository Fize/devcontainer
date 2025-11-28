.PHONY: build build-multi tag inspect-labels push run clean help

# 变量定义
LANG ?= go
GO_VER ?= 1.25.3
PY_VER ?= 3.13.1
NODE_VER ?= 24.11.1
CPP_VER ?= 17
REPO ?= malzaharguo/devcontainer
PLATFORM ?=
PLATFORMS ?= linux/amd64,linux/arm64

# 内部变量
DOCKERFILE = Dockerfile-$(LANG)
ifeq ($(LANG),go)
	VERSION = $(GO_VER)
	SHORT_LANG = go
else ifeq ($(LANG),python)
	VERSION = $(PY_VER)
	SHORT_LANG = py
else ifeq ($(LANG),node)
	VERSION = $(NODE_VER)
	SHORT_LANG = node
else ifeq ($(LANG),cpp)
	VERSION = $(CPP_VER)
	SHORT_LANG = cpp
else
	VERSION = unknown
	SHORT_LANG = unknown
endif
IMAGE_TAG = $(REPO):$(SHORT_LANG)$(VERSION)

# 单平台构建
build:
	@echo "Building $(SHORT_LANG) image version $(VERSION)..."
	docker buildx build \
		--build-arg $(shell echo $(LANG) | tr '[:lower:]' '[:upper:]')_VERSION=$(VERSION) \
		$(if $(PLATFORM),--platform=$(PLATFORM),) \
		-f $(DOCKERFILE) \
		-t devcontainer-$(LANG):local \
		-t $(IMAGE_TAG) \
		$(if $(PLATFORM),--load,) \
		.

# 多平台构建并推送
build-multi:
	@echo "Building multi-platform $(SHORT_LANG) image..."
	docker buildx build \
		--build-arg $(shell echo $(LANG) | tr '[:lower:]' '[:upper:]')_VERSION=$(VERSION) \
		--platform=$(PLATFORMS) \
		-f $(DOCKERFILE) \
		-t $(IMAGE_TAG) \
		-t $(REPO):$(SHORT_LANG)-latest \
		--push \
		.

# 推送单平台镜像
push: build
	docker push $(IMAGE_TAG)

# 运行容器验证
run: build
	docker run --rm -it devcontainer-$(LANG):local /bin/bash

# 验证构建（快速测试）
validate: build
	@echo "Validating $(LANG) image..."
	@if [ "$(LANG)" = "go" ]; then \
		docker run --rm devcontainer-$(LANG):local go version; \
	elif [ "$(LANG)" = "python" ]; then \
		docker run --rm devcontainer-$(LANG):local python3 --version; \
	elif [ "$(LANG)" = "node" ]; then \
		docker run --rm devcontainer-$(LANG):local node --version; \
	elif [ "$(LANG)" = "cpp" ]; then \
		docker run --rm devcontainer-$(LANG):local bash -c 'g++ --version && echo "int main(){}" | g++ -std=c++17 -x c++ -'; \
	else \
		echo "Unknown language"; \
	fi

# 清理
clean:
	-docker rmi devcontainer-$(LANG):local $(IMAGE_TAG) 2>/dev/null || true

# 构建所有语言
build-all:
	$(MAKE) build LANG=go
	$(MAKE) build LANG=python
	$(MAKE) build LANG=node
	$(MAKE) build LANG=cpp

# 推送所有语言
push-all:
	$(MAKE) push LANG=go
	$(MAKE) push LANG=python
	$(MAKE) push LANG=node
	$(MAKE) push LANG=cpp

# 帮助信息
help:
	@echo "Devcontainer Makefile - Language-specific Build System"
	@echo ""
	@echo "Required Variables:"
	@echo "  LANG        - Language to build (go, python, node, cpp)"
	@echo ""
	@echo "Optional Variables:"
	@echo "  GO_VER      - Go version (default: 1.25.3)"
	@echo "  PY_VER      - Python version (default: 3.13.1)"
	@echo "  NODE_VER    - Node.js version (default: 24.11.1)"
	@echo "  CPP_VER     - C++ standard (default: 17)"
	@echo "  PLATFORM    - Single platform (e.g., linux/arm64)"
	@echo "  PLATFORMS   - Multi platforms (default: linux/amd64,linux/arm64)"
	@echo "  REPO        - Repository (default: malzaharguo/devcontainer)"
	@echo ""
	@echo "Targets:"
	@echo "  make build LANG=go          - Build single platform"
	@echo "  make build-multi LANG=go    - Build and push multi-platform"
	@echo "  make push LANG=go           - Push single platform"
	@echo "  make run LANG=python        - Run container interactively"
	@echo "  make validate LANG=node     - Quick validation test"
	@echo "  make build-all              - Build all languages"
	@echo "  make push-all               - Push all languages"
	@echo "  make clean LANG=cpp         - Remove built images"
	@echo ""
	@echo "Examples:"
	@echo "  make build LANG=go"
	@echo "  make build LANG=python PY_VER=3.12.0"
	@echo "  make build-multi LANG=node PLATFORMS=linux/amd64,linux/arm64"
	@echo "  make validate LANG=cpp"
