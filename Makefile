HOME ?= $(shell pwd)
CONFIG ?= testnet

include ${CONFIG}.mk

TAG := $(file <data/hash.tag)
DOCKER_IMAGE ?= $(file <data/version)
DATA := $(realpath ./data)
CONTRACTS := $(realpath ./contracts)
UID = $(id -u)
GID = $(id -g)

export

.PHONY: create-config

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

container := $(shell if [ -r /var/run/docker.sock ]; then docker container ls | awk '/dyne\/dyneth/ { print $$1 }'; else echo "docker not running"; fi)

config: init
	$(info Docker image: '${DOCKER_IMAGE}')
	docker image inspect ${DOCKER_IMAGE}

init:
	@bash ./scripts/motd
	@mkdir -p ${DATA}
	$(if $(wildcard data/genesis.conf),$(if $(wildcard devops/genesis.conf),$(shell diff data/genesis.conf devops/genesis.conf)))
	@$(if $(wildcard devops/bootnodes.csv),cp -v devops/bootnodes.csv data/)
	@echo "NETWORK=${NETWORK}"    > ${DATA}/peerconf.sh
	@echo "P2P_PORT=${P2P_PORT}" >> ${DATA}/peerconf.sh
	@echo "API_PORT=${API_PORT}" >> ${DATA}/peerconf.sh

stopped:
	$(if ${container},\
	$(error Already running in docker container: ${container}),)

running:
	$(if ${container},,\
		$(error Container is not running))

##@ Server commands
start: run

run: init stopped upnp-open
run: ## start the API node listening on HTTP port
	$(info Using image: ${DOCKER_IMAGE})
	$(info Launching docker container for the HTTP API service:)
	docker  run --restart unless-stopped -d \
	--mount "type=bind,source=${CONTRACTS},destination=/contracts" \
	--mount "type=bind,source=${DATA},destination=/home/geth/.ethereum" \
	-p ${API_PORT}:${API_PORT} -p ${WS_PORT}:${WS_PORT} ${DOCKER_IMAGE} \
	  bash /start-geth-api.sh "${UID}"
	$(info P2P networking through port ${P2P_PORT})
	$(info HTTP API available at http://127.0.0.1:${API_PORT})
	$(info run 'make console' to attach the geth console)
	$(info run 'make shell' to attach the running docker)

create-config: NODE ?= api
create-config: ## create the configuration file for an API node
	$(info Creating configuration in data/)
	@bash ./scripts/create-config.sh ${NODE} "${NETWORK}" "${API_PORT}" "${P2P_PORT}"

run-signer: NODE ?= sign
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
run-signer-fg:
	$(info Launching docker container for the SIGNING service in foreground:)
	@docker run -it \
	--mount "type=bind,source=${DATA},destination=/home/geth/.ethereum" \
	 -p ${P2P_PORT}:${P2P_PORT}/tcp -p ${P2P_PORT}:${P2P_PORT}/udp \
	 ${DOCKER_IMAGE} bash /start-geth-signer.sh ${UID}

status: init
status: ## see if server is running and print public address
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
	@echo >&2 "Container running: ${container}"
	@echo >&2 "Executing command: ${CMD}"
	@docker exec -it --user geth ${container} ${CMD}
	@echo >&2 "Command executed: ${CMD}"

enr: running ## Obtain the ENR node record (admin.nodeInfo.enr)
	$(if $(wildcard data/geth/chaindata/CURRENT),,\
	$(error No genesis initialized on node))
	@docker exec -it --user geth ${container} geth attach --exec admin.nodeInfo.enr \
	| xargs | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"

console: init running
console: ## open the geth console inside running server
	@echo >&2 "Console starting"
	docker exec -it --user geth ${container} geth attach

command: CMD ?= eth.getBalance(eth.accounts[0])
command: init running
	@echo >&2 "Executing command: ${CMD}"
	@docker exec --user geth ${container} geth attach --exec "${CMD}"

stop:	init running upnp-close
stop: ## stop running server
	@echo >&2 "Stopping container: ${container}"
	@docker update --restart no ${container}
	@CMD="killall -INT geth" make shell
	@sh ./scripts/upnp.sh close ${P2P_PORT} tcp ;\
	 sh ./scripts/upnp.sh close ${P2P_PORT} udp

##@ Network commands

upnp-open: upnpc=$(shell which upnpc)
upnp-open: ## open UPNP port-forwarding on LAN router
	$(if $(wildcard ${upnpc}),,\
		$(info UPNP client not found, unable to open P2P port forwarding))
	@sh ./scripts/upnp.sh open ${P2P_PORT} tcp \
	&& sh ./scripts/upnp.sh open ${P2P_PORT} udp

upnp-close: upnpc=$(shell which upnpc)
upnp-close: ## close UPNP port-forwarding on LAN router
	$(if $(wildcard ${upnpc}),,\
		$(info UPNP client not found, unable to close P2P port forwarding))
	@sh ./scripts/upnp.sh close ${P2P_PORT} tcp \
	&& sh ./scripts/upnp.sh close ${P2P_PORT} udp

##@ Contract commands

contract-deploy: web3_deploy.py := $(shell mktemp)
contract-deploy: init running ## deploy a web3 smart-contract in SOL=contracts/file.sol
	$(if ${SOL},,$(error Contract file not specified, use SOL=contracts/file.sol))
	$(if ${GAS_LIMIT},,$(error Specify gas limit with GAS_LIMIT=21000))
	$(if ${GAS_PRICE},,$(error Specify gas price in Wei with GAS_PRICE=1000000))
	$(if ${PARAMS},,$(error "Missing params, PARAMS=\"\""))
	@docker exec -it ${container} sh -c \
	 "cd /contracts && solc --overwrite --bin --abi '$(notdir ${SOL})' -o build"
	@find contracts/build -type f
	@bash ./scripts/mk_web3_deploy.sh \
	 $(notdir $(basename ${SOL})) ${PARAMS} ${GAS_PRICE} ${GAS_LIMIT} >${web3_deploy.py}
	@cat ${web3_deploy.py} | docker exec -i ${container} python3
	@rm -f ${web3_deploy.py}

contract-info: web_info.py := $(shell mktemp)
contract-info: init ## obtain contract information about the TXID=hash
	$(if ${TXID},,$(error Transaction ID not specified, use TXID=hash))
	@sh ./scripts/mk_web3_info.sh ${TXID} > ${web_info.py}
	@cat ${web_info.py} | docker exec -i ${container} python3
	@rm -f ${web_info.py}

get-gas-price:
	@bash ./scripts/mk_web3_gasprice.sh | docker exec -i ${container} python3

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
	$(if $(wildcard data/genesis.json), $(error Cannot overwrite data/genesis.json))
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
	$(if $(wildcard data/geth/chaindata/CURRENT),\
		$(error Genesis already initialized on node))
	@docker run -it \
	 --mount type=bind,source=${DATA},destination=/home/geth/.ethereum \
	 ${DOCKER_IMAGE} geth init /home/geth/.ethereum/genesis.json
