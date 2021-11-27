SHELL=/bin/bash
NAME          := textlint
REVISION      := $(shell git rev-parse --short HEAD)
ORIGIN        := $(shell git remote get-url origin | sed -e 's/^.*@//g')
IMAGE_VERSION := 1.0.0
RELEASE_TAGS  := $(IMAGE_VERSION) $(IMAGE_VERSION)-$(REVISION)
REGISTRY      := docker.io
USER          := yassan

# 管理用

.PHONY: build
build:
	@echo "イメージビルド実行"
	docker build \
	--build-arg VERSION=$(IMAGE_VERSION) \
	--build-arg GIT_REVISION=$(REVISION) \
	--build-arg IMAGE_NAME=$(REGISTRY)/$(USER)/$(NAME) \
	$(addprefix -t $(REGISTRY)/$(USER)/$(NAME):,$(TAGS)) \
	-f ./docker/$(DOCKER_FILE) ./docker/ ;

.PHONY: push
push:
	@for TAG in $(TAGS); do\
		docker push $(REGISTRY)/$(USER)/$(NAME):$$TAG ;\
	done

.PHONY: release
release:
	@make build TAGS="$(RELEASE_TAGS)" DOCKER_FILE=Dockerfile
	@make push TAGS="$(RELEASE_TAGS)"
	@make clean TAGS="$(RELEASE_TAGS)"

.PHONY: clean
clean:
	@echo "コンテナイメージとクラスタ設定を削除"
	echo $(TAGS)
	@for TAG in $(TAGS); do \
		if [ -n "$$(docker images -q $(REGISTRY)/$(USER)/$(NAME):$$TAG)" ]; then \
			docker image rm -f $(REGISTRY)/$(USER)/$(NAME):$$TAG ; \
		fi \
	done ;

.PHONY: test
test:
	@echo "Test: 前回分のゴミ掃除"
	make clean TAGS="test"

	@echo "Test: テスト用イメージのビルド"
	make build TAGS="test" DOCKER_FILE=Dockerfile

	@echo "Test: テストの実施"
	docker run --rm $(REGISTRY)/$(USER)/$(NAME):test textlint -h ;

.PHONY: check
check:
	@echo "textlint実行（$(file)）"
	@docker run --rm -v $(PWD):/work $(REGISTRY)/$(USER)/$(NAME):$(IMAGE_VERSION) textlint $(file)
	@echo "check完了"

.PHONY: fix
fix:
	@echo "fix実施"
	@docker run --rm -v $(PWD):/work $(REGISTRY)/$(USER)/$(NAME):$(IMAGE_VERSION) textlint --fix $(file)
	@echo "fix完了"
