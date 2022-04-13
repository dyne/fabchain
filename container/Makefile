##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

##@ Development commands
include build.mk

DATA := $(realpath ../data)
CONTRACTS := $(realpath ../contracts)
TAG := $(file <${DATA}/hash.tag)
DOCKER_IMAGE := ${DOCKER}:${VERSION}-${TAG}

tag: ## compute the version tag for current build
	@mkdir -p data
	@find . -type f -print0 | sort -z \
	| xargs -0 sha1sum | sha1sum | awk '{print $$1}' \
	| tee ${DATA}/hash.tag.new \
	&& diff -q ${DATA}/hash.tag.new ${DATA}/hash.tag; \
	mv ${DATA}/hash.tag.new ${DATA}/hash.tag
	@echo "${DOCKER_IMAGE}" > ${DATA}/version

pull: ## pull the image from docker-hub online repo
	docker pull ${DOCKER_IMAGE}

push: tag ## push the image to docker-hub online repo
	docker push ${DOCKER_IMAGE}

build: tag ## build the docker container
	docker build . -t ${DOCKER_IMAGE} \
	 --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
	 --build-arg GETH_VERSION=${GETH_VERSION} \
	 --build-arg SOLC_VERSION=${SOLC_VERSION} \
	 --build-arg VERSION=${VERSION}

debug:
debug: ## run a shell in a new interactive container (no daemons)
	@echo >&2 "Data storage in ~/.ethereum"
	@echo >&2 "Debugging docker container:"
	docker run -it --user root \
	 --mount "type=bind,source=${DATA},destination=/home/geth/.ethereum" \
	 --mount "type=bind,source=${CONTRACTS},destination=/contracts" \
	 ${DOCKER_IMAGE} bash
