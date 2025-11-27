.PHONY: build build-multi tag inspect-labels push run clean help

# 变量定义
OS ?= debian
PLATFORM ?=
PLATFORMS ?= linux/amd64,linux/arm64
REPO ?= fize/devcontainer
GO_VER ?= 1.25.3
PY_VER ?= 3.13.1
NODE_VER ?= 24.12.0
TAG_EXTRA ?=
IMAGE_NAME = devcontainer-$(OS)
DOCKERFILE = Dockerfile-$(OS)

# 根据 OS 设置正确的 Dockerfile 映射
ifeq ($(OS),tencentos4)
	DOCKERFILE = Dockerfile-tencentos
else
	DOCKERFILE = Dockerfile-$(OS)
endif

# 构建参数
BUILD_ARGS = --build-arg GO_VERSION=$(GO_VER) \
             --build-arg PY_VERSION=$(PY_VER) \
             --build-arg NODE_VERSION=$(NODE_VER)

# 单平台构建
build:
	@echo "Building $(IMAGE_NAME) for OS=$(OS)..."
ifeq ($(PLATFORM),)
	docker build $(BUILD_ARGS) -f $(DOCKERFILE) -t $(IMAGE_NAME) .
else
	docker buildx build $(BUILD_ARGS) --platform=$(PLATFORM) -f $(DOCKERFILE) -t $(IMAGE_NAME) --load .
endif
	@echo "Build complete: $(IMAGE_NAME)"

# 多平台构建并推送
build-multi:
	@echo "Building multi-platform images for $(PLATFORMS)..."
	docker buildx build $(BUILD_ARGS) \
		--platform=$(PLATFORMS) \
		-f $(DOCKERFILE) \
		-t $(REPO):$(OS)-latest \
		--push .
	@echo "Multi-platform build complete and pushed"

# 打标签（系统+单语言）
tag: build
	@echo "Tagging images..."
	docker tag $(IMAGE_NAME) $(REPO):$(OS)-go$(GO_VER)$(TAG_EXTRA)
	docker tag $(IMAGE_NAME) $(REPO):$(OS)-py$(PY_VER)$(TAG_EXTRA)
	docker tag $(IMAGE_NAME) $(REPO):$(OS)-node$(NODE_VER)$(TAG_EXTRA)
	docker tag $(IMAGE_NAME) $(REPO):$(OS)-cpp17$(TAG_EXTRA)
	@echo "Tags created:"
	@echo "  $(REPO):$(OS)-go$(GO_VER)$(TAG_EXTRA)"
	@echo "  $(REPO):$(OS)-py$(PY_VER)$(TAG_EXTRA)"
	@echo "  $(REPO):$(OS)-node$(NODE_VER)$(TAG_EXTRA)"
	@echo "  $(REPO):$(OS)-cpp17$(TAG_EXTRA)"

# 标签一致性校验
inspect-labels: build
	@echo "Inspecting image labels..."
	@GO_LABEL=$$(docker inspect --format='{{index .Config.Labels "org.opencontainers.image.version.go"}}' $(IMAGE_NAME)); \
	PY_LABEL=$$(docker inspect --format='{{index .Config.Labels "org.opencontainers.image.version.python"}}' $(IMAGE_NAME)); \
	NODE_LABEL=$$(docker inspect --format='{{index .Config.Labels "org.opencontainers.image.version.node"}}' $(IMAGE_NAME)); \
	echo "Expected: GO=$(GO_VER), PY=$(PY_VER), NODE=$(NODE_VER)"; \
	echo "Actual:   GO=$$GO_LABEL, PY=$$PY_LABEL, NODE=$$NODE_LABEL"; \
	if [ "$$GO_LABEL" != "$(GO_VER)" ] || [ "$$PY_LABEL" != "$(PY_VER)" ] || [ "$$NODE_LABEL" != "$(NODE_VER)" ]; then \
		echo "ERROR: Version mismatch!"; \
		exit 1; \
	fi; \
	echo "✓ Label consistency check passed"

# 推送镜像
push: tag
	@echo "Pushing images to $(REPO)..."
	docker push $(REPO):$(OS)-go$(GO_VER)$(TAG_EXTRA)
	docker push $(REPO):$(OS)-py$(PY_VER)$(TAG_EXTRA)
	docker push $(REPO):$(OS)-node$(NODE_VER)$(TAG_EXTRA)
	docker push $(REPO):$(OS)-cpp17$(TAG_EXTRA)
	@echo "Push complete"

# 运行容器
run: build
	@echo "Running $(IMAGE_NAME)..."
	docker run --rm -it $(IMAGE_NAME) /bin/zsh

# 清理
clean:
	@echo "Cleaning up..."
	-docker rmi $(IMAGE_NAME) 2>/dev/null || true
	@echo "Clean complete"

# 帮助信息
help:
	@echo "Devcontainer Makefile Usage:"
	@echo ""
	@echo "Variables:"
	@echo "  OS          - debian or tencentos4 (default: debian)"
	@echo "  PLATFORM    - Target platform (default: current, e.g., linux/amd64)"
	@echo "  PLATFORMS   - Multi-platform list (default: linux/amd64,linux/arm64)"
	@echo "  REPO        - Repository name (default: fize/devcontainer)"
	@echo "  GO_VER      - Go version (default: $(GO_VER))"
	@echo "  PY_VER      - Python version (default: $(PY_VER))"
	@echo "  NODE_VER    - Node.js version (default: $(NODE_VER))"
	@echo "  TAG_EXTRA   - Extra tag suffix (default: empty)"
	@echo ""
	@echo "Targets:"
	@echo "  make build              - Build single-platform image"
	@echo "  make build-multi        - Build and push multi-platform images"
	@echo "  make tag                - Tag image with language versions"
	@echo "  make inspect-labels     - Verify label consistency"
	@echo "  make push               - Push tagged images"
	@echo "  make run                - Run container interactively"
	@echo "  make clean              - Remove built images"
	@echo ""
	@echo "Examples:"
	@echo "  make build OS=debian"
	@echo "  make build OS=tencentos4 PLATFORM=linux/arm64"
	@echo "  make build-multi OS=debian PLATFORMS=linux/amd64,linux/arm64"
	@echo "  make tag OS=debian"
	@echo "  make run OS=tencentos4"
