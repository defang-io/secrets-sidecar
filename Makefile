# VERSION is the version we should download and use.
VERSION:=$(shell git rev-parse --short HEAD)
# DOCKER is the docker image repo we need to push to.
DOCKER:=lionello
DOCKER_IMAGE_NAME:=$(DOCKER)/secrets-sidecar

DOCKER_IMAGE_ARM64:=$(DOCKER_IMAGE_NAME):arm64-$(VERSION)
DOCKER_IMAGE_AMD64:=$(DOCKER_IMAGE_NAME):amd64-$(VERSION)

.PHONY: help
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/:.*##/:/'

.PHONY: build
build: ## Build a local binary
	go build ./secrets.go

.PHONY: docker-amd64
docker-amd64:
	docker build --platform linux/amd64 -t secrets-sidecar -t $(DOCKER_IMAGE_AMD64) .

.PHONY: docker-arm64
docker-arm64:
	docker build --platform linux/arm64 -t secrets-sidecar -t $(DOCKER_IMAGE_ARM64) .

.PHONY: docker
docker: docker-amd64 docker-arm64 ## Build all docker images

.PHONY: push
push: docker login ## Push all docker images and manifest
	docker push $(DOCKER_IMAGE_AMD64)
	docker push $(DOCKER_IMAGE_ARM64)
	docker manifest create --amend $(DOCKER_IMAGE_NAME):$(VERSION) $(DOCKER_IMAGE_AMD64) $(DOCKER_IMAGE_ARM64)
	docker manifest create --amend $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_AMD64) $(DOCKER_IMAGE_ARM64)
	docker manifest push --purge $(DOCKER_IMAGE_NAME):$(VERSION)
	docker manifest push --purge $(DOCKER_IMAGE_NAME):latest

.PHONY: login
login: ## Login to docker
	@docker login
