include config.mk

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>[-steps] (play target or just show its -steps)\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

ssh-keygen: ## generate a dedicated ssh keypair here
	$(if $(wildcard ${sshkey}),, \
		$(info Generating ssh keypair) \
		ssh-keygen -t ed25519 -f ${sshkey} -q -N '')

steps:
	@cat $(subst -steps,,${MAKECMDGOALS}).yaml | grep '\- name'

play: ARGS := $(if $(wildcard hosts.toml),--inventory hosts.toml)
play:
	ansible-playbook ${MAKECMDGOALS}.yaml ${ARGS}

##@ Application management

install-sign: inventory play ## install all sign nodes
install-sign-steps: steps

install-api: inventory play ## install all api nodes
install-api-steps: steps

start: inventory play ## start all applications (ROLE=sign by default)
start-steps: steps

stop: play ## stop all applications
stop-steps: steps

upgrade-offline: play ## update all app containers while off-line (no restart)
upgrade-offline-steps: steps

upgrade-restart: play ## update all app containers while on-line (stop-update-start)
upgrade-restart-steps: steps

list-addresses: play ## list all app public addressess
list-addresses-steps: steps

list-bootnodes: play ## list all app ENR addresses and write data/bootnodes.csv
list-bootnodes-steps: steps

##@ Server management

inventory:
inventory:
	@echo "[sign]" > hosts.toml
	@hcloud server list -o noheader -o columns=name,ipv4 \
	| awk '/sign/{print $$2}' >> hosts.toml
	@echo "[api]" >> hosts.toml
	@hcloud server list -o noheader -o columns=name,ipv4 \
	| awk '/api/{print $$2}' >> hosts.toml
	@cat hosts.toml

list-datacenters:
	@curl -sLH "Authorization: Bearer ${API_TOKEN}" \
	'https://api.hetzner.cloud/v1/datacenters' \
	| awk '/name.*-dc/{ print $$2 }' | sed 's/,//' | xargs

server-create: DATACENTERS := "nbg1-dc3 hel1-dc2 fsn1-dc14"
server-create: ## create all servers on hcloud, 3 signers and 1 api
	bash ./hcloud-create-3-1.sh ${DATACENTERS}

server-cmd: CMD ?= describe
server-cmd:
	./hcloud-server-foreach.sh ${CMD}

list-uptimes: inventory play ## list all server uptimes
list-uptimes-steps: steps

