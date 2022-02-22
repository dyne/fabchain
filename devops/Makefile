R ?= $(shell pwd)

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>[-steps] (play target or just show its -steps)\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

ANSIPLAY = ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --inventory hosts.toml --ssh-common-args '-o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes' --private-key ./sshkey $(1)

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

signers-exec: IPS := $(shell hcloud server list -o noheader -o columns=ipv4 | xargs)
signers-exec: CMD ?= eth.getBalance(eth.accounts[0])
signers-exec: ## execute a geth console command on all signers
	for i in ${IPS}; do ssh -i ./sshkey \
	  -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes \
	  "app@$$i" "cd dyneth && make command CMD='${CMD}'" ;\
	done

##@ Genesis management

list-addresses: inventory ## list all app public addressess
	$(call ANSIPLAY, list-addresses.yaml)
list-addresses-steps: steps

init-genesis: inventory ## initialize genesis on all nodes
	$(if $(wildcard genesis.json),,$(error Genesis file not found))
	$(call ANSIPLAY, init-genesis.yaml)

init-bootnodes: inventory ## generate bootnodes from signer ENR addresses
	$(call ANSIPLAY, init-bootnodes.yaml)
	bash ./join_enr.sh
	make upload-bootnodes

init-bootnodes-steps: steps

upload-bootnodes: IPS := $(shell hcloud server list -o noheader -o columns=ipv4 | xargs)
upload-bootnodes: ## upload bootnodes.csv (used by init-bootnodes)
	$(if $(wildcard bootnodes.csv),,$(error Bootnodes file not found))
	for i in ${IPS}; do scp -i ./sshkey \
	  -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes \
	  bootnodes.csv "app@$$i:dyneth/data/" ; \
	done
	make stop
	make start

##@ Server management

list-datacenters: ## list all available datacenters
	@echo
	@hcloud datacenter list | awk '/NAME/{next} {print $$2}' | xargs
	@echo; echo "fill DATACENTERS in Makefile accordingly."

server-create: DATACENTERS := "nbg1-dc3 hel1-dc2 fsn1-dc14"
server-create: ## create all servers on hcloud, 3 signers and 1 api
	bash ./hcloud-create-3-1.sh ${DATACENTERS}

inventory:
inventory: ## create an ansible inventory (used internally)
	@echo "[sign]" > hosts.toml
	@hcloud server list -o noheader -o columns=name,ipv4 \
	| awk '/sign/{print $$2}' >> hosts.toml
	@echo "[api]" >> hosts.toml
	@hcloud server list -o noheader -o columns=name,ipv4 \
	| awk '/api/{print $$2}' >> hosts.toml

install: ssh-keygen inventory
install: ## install all servers and create new accounts
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

