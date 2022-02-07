HOME ?= $(shell pwd)

include config.mk

export

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

all:
	@echo "Dyneth ${VERSION}" && echo
	@echo "Server commands:" ;\
	 echo " make run - start the API node listening on HTTP port ${API_PORT}" ;\
	 echo " make shell - open a shell inside running server (CMD=sh or custom)" ;\
	 echo " make status - see if server is running and print public address" ;\
	 echo " make stop - stop running server" ;\
	 echo
	@echo "Account commands:" ;\
	 echo " make account - create a new private account in ~/.dyneth/keystore" ;\
	 echo " make backup  - prints the private account contents as JSON string" ;\
	 echo " make restore - asks for private account string to restore from backup" ;\
	 echo " make run-signer - start the SIGNER node with current account" ;\
	 echo
	@echo "Development commands:" ;\
	 echo " make debug - run a shell in a new interactive container (no daemons)" ;\
	 echo " make build - build the local ./Dockerfile as dyne/dyneth:latest" ;\
	 echo

container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')

init:
	@bash ./scripts/motd
	@mkdir -p ${DATA}

stopped:
	@if [ ! "x${container}" = "x" ]; then \
		echo "Already running in docker container: ${container}"; echo; exit 1; fi

running:
	@if [ "x${container}" = "x" ]; then \
		echo "Container is not running"; echo; exit 1; fi

##@ Server commands

run:	init stopped upnp-open
run: ## start the API node listening on HTTP port
	@echo "Launching docker container for the HTTP API service:"
	@docker  run --restart unless-stopped -d --mount "type=bind,source=${CONTRACTS},destination=/contracts" -p ${API_PORT}:${API_PORT} ${DOCKER}:${VERSION} \
	  sh /start-geth-api.sh ${UID}
	@echo "P2P networking through port 30303"
	@echo "HTTP API available at port ${API_PORT}"
	@echo "run 'make console' to attach the geth console"
	@echo "run 'make shell' to attach the running docker" && echo

run-signer: init stopped upnp-open
run-signer: ## start the SIGNER node networking on the P2P port
	@echo "Launching docker container for the SIGNING service:"
	@docker run -it \
	--mount type=bind,source=${DATA},destination=/home/geth/.ethereum \
	 -p ${P2P_PORT}:${P2P_PORT}/tcp -p ${P2P_PORT}:${P2P_PORT}/udp \
	 ${DOCKER}:${VERSION} sh /start-geth-signer.sh ${UID}
	@echo "P2P networking through port ${P2P_PORT}"
	@echo "run 'make shell' for an interactive console" && echo

status: init
status: ## see if server is running and print public address
	@if [ "x${container}" = "x" ]; then \
		echo "Status: NOT RUNNING" && echo ;\
	else \
		echo "Status: RUNNING" && echo ;\
	fi

shell:	init running
shell:	CMD ?= "bash"
shell: ## open a shell inside running server (CMD=sh or custom)
	@echo "Container running: ${container}"
	@echo "Executing command: ${CMD}" && echo
	docker exec -it --user geth ${container} ${CMD}
	@echo && echo "Command executed: ${CMD}" && echo

console: init running
console: ## open the geth console inside running server
	echo "Console starting" && echo
	docker exec -it --user geth ${container} geth attach

stop:	init running upnp-close
stop: ## stop running server
	@echo "Stopping container: ${container}"
	@docker container stop ${container}
	@sh ./scripts/upnp.sh close ${P2P_PORT} tcp ;\
	 sh ./scripts/upnp.sh close ${P2P_PORT} udp

##@ Network commands

upnp-open: upnpc=$(shell which upnpc)
upnp-open: ## open UPNP port-forwarding on LAN router
	@if [ "x${upnpc}" = "x" ]; then \
	 echo "UPNP client not found, unable to open P2P port forwarding" ;\
	else \
	 sh ./scripts/upnp.sh open ${P2P_PORT} tcp ;\
	 sh ./scripts/upnp.sh open ${P2P_PORT} udp ;\
	fi

upnp-close: upnpc=$(shell which upnpc)
upnp-close: ## close UPNP port-forwarding on LAN router
	@if [ "x${upnpc}" = "x" ]; then \
	 echo "UPNP client not found, unable to close P2P port forwarding" ;\
	else \
	 sh ./scripts/upnp.sh close ${P2P_PORT} tcp ;\
	 sh ./scripts/upnp.sh close ${P2P_PORT} udp ;\
	fi


deploy: init running
	@bash ./scripts/deploy.sh

receipt: init
	@bash ./scripts/receipt.sh

##@ Account commands:
account: init ## create a new private account in data/keystore
	@if [ "x${PASS}" = "x" ]; then \
	  echo "PASS is not defined" ;\
	else \
	  echo "${PASS}" | tee "${DATA}/passfile" >/dev/null ;\
	  bash ./scripts/account.sh new ;\
	  rm -rf "${DATA}/passfile" ;\
	fi

backup: init ## print the private account content as JSON string
	@bash ./scripts/account.sh backup

backup-secret: init ## print the wallet master secret key
	@bash ./scripts/secret.sh

restore: init ## ask for private account JSON to restore backup
	@bash ./scripts/account.sh restore

##@ Genesis commands
genesis: epoch := $(shell date +"%s")
genesis: genesis_tmp := $(shell mktemp)
genesis: sh_tmp := $(shell mktemp)
genesis: ## Create a new genesis
	@bash ./scripts/ask_stakeholders.sh > ${sh_tmp}
	@echo -n ${epoch} > ${genesis_tmp}
	@zenroom scripts/genesis.lua -a ${genesis_tmp} -k ${sh_tmp}
	@rm -f ${sh_tmp} ${genesis_tmp}

##@ Development commands

build: ## build the docker container
	make -C devops

build-release:
	make -C devops

debug:	init stopped
debug: ## run a shell in a new interactive container (no daemons)
	@echo "P2P networking through port ${P2P_PORT}"
	@echo "HTTP API available at port ${API_PORT}"
	@echo "Data storage in ~/.dyneth" && echo
	@echo "Debugging docker container:"
	docker run -it --user root -p ${P2P_PORT}:${P2P_PORT}/tcp \
	 -p ${P2P_PORT}:${P2P_PORT}/udp -p ${API_PORT}:${API_PORT} \
	 --mount type=bind,source=${DATA},destination=/home/geth/.ethereum \
	 --mount "type=bind,source=${CONTRACTS},destination=/contracts" \
	 ${DOCKER}:${VERSION} bash

