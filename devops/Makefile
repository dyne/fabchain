R ?= $(shell pwd)

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>[-steps] (play target or just show its -steps)\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

ANSIPLAY = ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --inventory hosts.toml --ssh-common-args '-o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes' --private-key ./sshkey $(1)

hcloud-token:
	include config.mk

ssh-keygen: ## generate a dedicated ssh keypair here
	$(if $(wildcard ./sshkey),, \
		$(info Generating ssh keypair) \
		ssh-keygen -t ed25519 -f ./sshkey -q -N '')

steps:
	@cat $(subst -steps,,${MAKECMDGOALS}).yaml | grep '\- name'

##@ Application management

start: ## start all applications
	$(call ANSIPLAY, start-signers.yaml)
	$(call ANSIPLAY, start-apis.yaml)

stop: ## stop all applications
	$(call ANSIPLAY, stop.yaml)

upgrade: inventory ## upgrade all applications to latest container tag
	make stop
	$(call ANSIPLAY, upgrade.yaml)
	make start

install-explorer: inventory ## install the block explorer on the api node
	$(call ANSIPLAY, install-explorer.yaml)

##@ Genesis management

list-addresses: inventory ## list all app public addressess
	$(call ANSIPLAY, list-addresses.yaml)
list-addresses-steps: steps

init-bootnodes: inventory ## list all app ENR bootnode addresses
	$(call ANSIPLAY, init-bootnodes.yaml)
	bash ./join_enr.sh
	make upload-bootnodes

init-bootnodes-steps: steps

upload-bootnodes: IPS := $(shell hcloud server list -o noheader -o columns=ipv4 | xargs)
upload-bootnodes: ## upload bootnodes.csv (used by init-bootnodes)
	for i in ${IPS}; do scp -i ./sshkey \
	  -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes \
	  bootnodes.csv "app@$$i:dyneth/data/" ; \
	done
	make stop
	make start

##@ Server management

list-datacenters:
	@echo
	@hcloud datacenter list | awk '/NAME/{next} {print $$2}' | xargs
	@echo; echo "fill DATACENTERS in Makefile accordingly."

server-create: DATACENTERS := "nbg1-dc3 hel1-dc2 fsn1-dc14"
server-create: ## create all servers on hcloud, 3 signers and 1 api
	bash ./hcloud-create-3-1.sh ${DATACENTERS}

inventory:
inventory:
	@echo "[sign]" > hosts.toml
	@hcloud server list -o noheader -o columns=name,ipv4 \
	| awk '/sign/{print $$2}' >> hosts.toml
	@echo "[api]" >> hosts.toml
	@hcloud server list -o noheader -o columns=name,ipv4 \
	| awk '/api/{print $$2}' >> hosts.toml

install: ssh-keygen inventory ## install all sign nodes
install:
	$(call ANSIPLAY, install.yaml)

install-steps: steps

ssh: HOST ?= sign-1
ssh:
	ssh $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/${HOST}/{print $$2}') \
	 -l root -i ./sshkey -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes 

server-cmd: CMD ?= describe
server-cmd: ## execute an hcloud server command on all nodes
	./hcloud-server-foreach.sh ${CMD}

list-uptimes: inventory ## list all server uptimes
	$(call ANSIPLAY, list-uptimes.yaml)

