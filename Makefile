HOME ?= $(shell pwd)

include config.mk

export

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')

config: init
	$(info Docker image: '${DOCKER_IMAGE}')
	$(info Chain ID: '${NETWORK_ID}')
	@cat ${DATA}/peerconf.sh

init:
	@bash ./scripts/motd
	@mkdir -p ${DATA}
	$(file > ${DATA}/peerconf.sh,NETWORK_ID=${NETWORK_ID})
	$(file >> ${DATA}/peerconf.sh,P2P_PORT=${P2P_PORT})
	$(file >> ${DATA}/peerconf.sh,API_PORT=${API_PORT})

stopped:
	$(if ${container},\
	$(error Already running in docker container: ${container}),)

running:
	$(if ${container},,\
		$(error Container is not running))

##@ Server commands

run:	init stopped upnp-open
run: ## start the API node listening on HTTP port
	$(info Launching docker container for the HTTP API service:)
	@docker  run --restart unless-stopped -d \
	--mount "type=bind,source=${CONTRACTS},destination=/contracts" \
	--mount "type=bind,source=${DATA},destination=/home/geth/.ethereum" \
	-p ${API_PORT}:${API_PORT} ${DOCKER_IMAGE} \
	  bash /start-geth-api.sh ${UID} ${SYNCMODE}
	$(info P2P networking through port ${P2P_PORT})
	$(info HTTP API available at port ${API_PORT})
	$(info run 'make console' to attach the geth console)
	$(info run 'make shell' to attach the running docker)

run-signer: init stopped upnp-open
run-signer: ## start the SIGNER node networking on the P2P port
	$(info Launching docker container for the SIGNING service:)
	@docker run --restart unless-stopped -d \
	--mount "type=bind,source=${DATA},destination=/home/geth/.ethereum" \
	 -p ${P2P_PORT}:${P2P_PORT}/tcp -p ${P2P_PORT}:${P2P_PORT}/udp \
	 ${DOCKER_IMAGE} bash /start-geth-signer.sh ${UID}
	$(info P2P networking through port ${P2P_PORT})
	$(info run 'make shell' for an interactive console)

run-signer-fg: init stopped upnp-open
run-signer-fg: ## start the SIGNER node networking on the P2P port
	$(info Launching docker container for the SIGNING service in foreground:)
	@docker run -it \
	--mount "type=bind,source=${DATA},destination=/home/geth/.ethereum" \
	 -p ${P2P_PORT}:${P2P_PORT}/tcp -p ${P2P_PORT}:${P2P_PORT}/udp \
	 ${DOCKER_IMAGE} sh /start-geth-signer.sh ${UID}

status: init
status: ## see if server is running and print public addres
	$(if ${container},\
		$(info Status: RUNNING),\
		$(info Status: NOT RUNNING))

logs: init running
logs: ## show the logs of the running server
	$(info Container running: ${container})
	docker logs ${container} -f

shell:	init running
shell:	CMD ?= "bash"
shell: ## open a shell inside running server (CMD=sh or custom)
	$(info "Container running: ${container}")
	$(info "Executing command: ${CMD}") && echo
	docker exec -it --user geth ${container} ${CMD}
	&& $(info Command executed: ${CMD})

enr: running ## Obtain the ENR node record (admin.nodeInfo.enr)
	$(if $(wildcard data/geth/chaindata/CURRENT),,\
	$(error No genesis initialized on node))
	@docker exec -it --user geth ${container} geth attach --exec admin.nodeInfo.enr \
	| xargs | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"

console: init running
console: ## open the geth console inside running server
	$(info Console starting)
	docker exec -it --user geth ${container} geth attach

stop:	init running upnp-close
stop: ## stop running server
	$(info Stopping container: ${container})
	@docker container stop ${container}
	@sh ./scripts/upnp.sh close ${P2P_PORT} tcp ;\
	 sh ./scripts/upnp.sh close ${P2P_PORT} udp

##@ Network commands

upnp-open: upnpc=$(shell which upnpc)
upnp-open: ## open UPNP port-forwarding on LAN router
	$(if $(wildcard ${upnpc}),,\
		$(warning "UPNP client not found, unable to open P2P port forwarding"))
	@sh ./scripts/upnp.sh open ${P2P_PORT} tcp \
	&& sh ./scripts/upnp.sh open ${P2P_PORT} udp

upnp-close: upnpc=$(shell which upnpc)
upnp-close: ## close UPNP port-forwarding on LAN router
	$(if $(wildcard ${upnpc}),,\
		$(warning "UPNP client not found, unable to close P2P port forwarding"))
	@sh ./scripts/upnp.sh close ${P2P_PORT} tcp \
	&& sh ./scripts/upnp.sh close ${P2P_PORT} udp

deploy: init running
	@bash ./scripts/deploy.sh

receipt: init
	@bash ./scripts/receipt.sh

##@ Account commands:
account: init ## create a new private account in data/keystore
	$(if ${PASS},,$(error PASS is not defined))
	@umask 177 \
	&& echo "${PASS}" > "${DATA}/passfile" \
	&& bash ./scripts/account.sh new

backup: init ## print the private account content as JSON string
	@bash ./scripts/account.sh backup

backup-secret: init ## print the wallet master secret key
	@bash ./scripts/secret.sh

restore: init ## ask for private account JSON to restore backup
	@bash ./scripts/account.sh restore

##@ Genesis commands
genesis-create: ## Create data/genesis.json from parameters in scripts/params_genesis.json
	@if [ -r data/genesis.json ]; then \
		echo "Cannot overwrite data/genesis.json"; exit 1; fi
	$(if $(wildcard scripts/params_genesis.json),,\
		$(error Genesis parameters not found in scripts/params_genesis.json))
	@zenroom scripts/genesis.lua -a scripts/params_genesis.json | jq . | tee data/genesis.json
	@echo
	@echo "###########################"
	@echo "now RUN: make genesis-init"
	@echo "###########################"
	@echo

genesis-init: ## Initialize node to use the new chain in data/genesis.json
	$(if $(wildcard data/genesis.json),,\
		$(error "Cannot find data/genesis.json, run 'make genesis-create' first"))
	@docker run -it \
	 --mount type=bind,source=${DATA},destination=/home/geth/.ethereum \
	 ${DOCKER_IMAGE} geth init /home/geth/.ethereum/genesis.json

##@ Development commands

tag: ## compute the version tag for current build
	@mkdir -p data
	@find container -type f -print0 | sort -z \
	| xargs -0 sha1sum | sha1sum | awk '{print $$1}' \
	| tee data/hash.tag

pull: ## pull the image from docker-hub online repo
	docker pull ${DOCKER_IMAGE}

push: tag ## push the image to docker-hub online repo
	docker push ${DOCKER_IMAGE}

build: tag ## build the docker container
	docker build -t ${DOCKER_IMAGE} \
	 --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
	 --build-arg GETH_VERSION=${GETH_VERSION} \
	 --build-arg SOLC_VERSION=${SOLC_VERSION} \
	 --build-arg VERSION=${VERSION} \
	 -f container/Dockerfile container

debug:	init stopped
debug: ## run a shell in a new interactive container (no daemons)
	@echo "P2P networking through port ${P2P_PORT}"
	@echo "HTTP API available at port ${API_PORT}"
	@echo "Data storage in ~/.dyneth" && echo
	@echo "Debugging docker container:"
	docker run -it --user root -p ${P2P_PORT}:${P2P_PORT}/tcp \
	 -p ${P2P_PORT}:${P2P_PORT}/udp -p ${API_PORT}:${API_PORT} \
	 --mount "type=bind,source=${DATA},destination=/home/geth/.ethereum" \
	 --mount "type=bind,source=${CONTRACTS},destination=/contracts" \
	 ${DOCKER_IMAGE} bash

