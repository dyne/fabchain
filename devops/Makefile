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
	ansible-playbook ${MAKECMDGOALS}.yaml ${ARGS} \
	 --ssh-common-args '-o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes' \
	 --private-key ./sshkey

##@ Application management

install: inventory ## install all sign nodes
install:
	ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook --inventory hosts.toml \
	--ssh-common-args '-o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes' \
	--private-key ./sshkey install.yaml

install-steps: steps

start: inventory ## start all applications (ROLE=sign by default)
start:
	ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook start-signers.yaml --inventory hosts.toml \
	--ssh-common-args '-o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes' \
	--private-key ./sshkey
	ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook start-apis.yaml --inventory hosts.toml \
	--ssh-common-args '-o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes' \
	--private-key ./sshkey

stop: play ## stop all applications

upgrade-offline: play ## update all app containers while off-line (no restart)
upgrade-offline-steps: steps

upgrade-restart: play ## update all app containers while on-line (stop-update-start)
upgrade-restart-steps: steps

##@ Genesis management

list-addresses: play ## list all app public addressess
list-addresses-steps: steps

init-bootnodes: play ## list all app ENR bootnode addresses
init-bootnodes-steps: steps

##@ Server management

ssh: NODE ?= sign-1
ssh:
	ssh $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/${NODE}/{print $$2}') \
	 -l root -i ./sshkey -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes 

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
server-cmd: ## execute an hcloud server command on all nodes
	./hcloud-server-foreach.sh ${CMD}

list-uptimes: inventory play ## list all server uptimes
list-uptimes-steps: steps

