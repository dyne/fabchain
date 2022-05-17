R ?= $(realpath .)
CONFIG := $(shell hcloud context active)
include ../${CONFIG}.mk

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

wipe-blockchain: ## delete all blockchain data
	$(call ANSIPLAY, delete-blockchain.yaml)

start-signers: DOCKER_IMAGE ?= ""
start-signers: ## start all signers
ifeq (${DOCKER_IMAGE},)
	$(call ANSIPLAY, start-signers.yaml)
else
	$(call ANSIPLAY, start-signers.yaml --extra-vars="DOCKER_IMAGE=${DOCKER_IMAGE}")
endif

start-apis: ## start all apis
	$(call ANSIPLAY, start-apis.yaml)

stop: ## stop all applications
	$(call ANSIPLAY, stop.yaml)

upgrade: inventory ## upgrade all applications to latest container tag
	make stop
	$(call ANSIPLAY, upgrade.yaml)
	make start

remote-exec: ON ?= sign
remote-exec: IPS := $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/${ON}/{print $$2}' | xargs)
remote-exec: CMD ?= eth.getBalance(eth.accounts[0])
remote-exec: ## execute a geth console command on all signers
	@for i in ${IPS}; do echo >&2 "\nHost: $$i" ; ssh -i ./sshkey \
	  -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes \
	  "app@$$i" "cd dyneth && make command CMD='${CMD}' 2>/dev/null" ;\
	done

remote-shell: ON ?= sign
remote-shell: IPS := $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/${ON}/{print $$2}' | xargs)
remote-shell: CMD ?= top -b -d 5 -n 3 | head -n 15
remote-shell: ## execute a shell command on all signers
	@for i in ${IPS}; do echo >&2 "\nHost: $$i" ; ssh -i ./sshkey \
	  -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes \
	  "app@$$i" "cd dyneth && TERM=linux ${CMD}" ;\
	done

create-config:
	make remote-shell CMD='make create-config NODE=sign' ON=sign-1
	make remote-shell CMD='make create-config NODE=sign' ON=sign-2
	make remote-shell CMD='make create-config NODE=sign' ON=sign-3
	make remote-shell CMD='make create-config NODE=api' ON=api


remote-copy: ON ?= sign
remote-copy: IPS := $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/${ON}/{print $$2}' | xargs)
remote-copy: FILE ?= bootnodes.csv
remote-copy: ## upload a file on all nodes
	$(if $(wildcard ${FILE}),,$(error File not found: ${FILE}))
	@for i in ${IPS}; do scp -i ./sshkey \
	  -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes \
	  ${FILE} "app@$$i:dyneth/data/" ; \
	done

##@ Treasury management

send-funds: ADDR ?= $(shell make remote-exec CMD="eth.accounts[0]" ON=api | xargs)
send-funds: AMOUNT ?= 1
send-funds: ## Send an amount of funds from each signer to an address (default 1 to API)
	$(info API address: ${ADDR})
	$(info Amount to fund from each signer: ${AMOUNT})
	make remote-shell CMD='bash scripts/send_transaction.sh ${ADDR} ${AMOUNT}'

##@ Genesis management

genesis-create: SIGNERS=""
genesis-create:
	@make -C .. genesis-create SIGNERS=${SIGNERS}
	@make init-genesis

list-addresses: CMD := eth.accounts[0]
list-addresses: inventory ## list all app public addressess
	@echo; echo "### Signers:"
	@make -s remote-shell CMD="CONFIG=${CONFIG} make status 2>&1 | awk '/Public address/ {print $$3}'" ON=sign
	@echo; echo; echo "### Api:"
	@make -s remote-shell CMD="CONFIG=${CONFIG} make status 2>&1 | awk '/Public address/ {print $$3}'" ON=api
	@echo

init-genesis: inventory ## initialize genesis on all nodes
	$(if $(wildcard ../data/genesis.json),,$(error Genesis file not found))
	make remote-copy FILE=../data/genesis.json ON=sing
	make remote-copy FILE=../data/genesis.json ON=api
	$(call ANSIPLAY, init-genesis.yaml)

create-bootnodes: inventory ## create current list of bootnodes
	$(call ANSIPLAY, create-bootnodes.yaml)
	@bash ./join_enodes.sh
	$(info Bootnode enodes entries created in bootnodes.csv)


# obsolete
init-bootnodes: inventory # generate bootnodes from signer ENR addresses
	$(call ANSIPLAY, init-bootnodes.yaml)
	bash ./join_enodes.sh
	#make upload-bootnodes
update-bootnodes: inventory # generate bootnodes from signer ENR addresses
	$(call ANSIPLAY, update-bootnodes.yaml)
	bash ./join_enodes.sh
upload-bootnodes: IPS := $(shell hcloud server list -o noheader -o columns=ipv4 | xargs)
upload-bootnodes: # upload bootnodes.csv (used by init-bootnodes)
	$(if $(wildcard bootnodes.csv),,$(error Bootnodes file not found))
	for i in ${IPS}; do scp -i ./sshkey \
	  -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes \
	  bootnodes.csv "app@$$i:dyneth/data/" ; \
	done
	make stop
	make start

pack-genesis:
	tar cvfj - genesis.json bootnodes.csv  | base64

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
install: ## install all servers
	$(call ANSIPLAY, install.yaml)
install-steps: steps

install-firewall: SIGNERS := [ $(shell hcloud server list -o columns=name,ipv4 | awk '/sign/{printf "'"'"'%s'"'"',",$$2} END{printf"\n"}') ]
install-firewall: SERVERS := [ $(shell hcloud server list -o noheader -o columns=ipv4 | awk '{printf "'"'"'%s'"'"',",$$1} END{printf"\n"}') ]
install-firewall: API_PORTS := [ '${API_PORT}', ${WS_PORT}, '8000', '5000', '9080' ]
install-firewall: SIGN_PORTS := [ '${P2P_PORT}', '9080' ]
install-firewall: inventory ## setup firewall rules on all nodes (API_ and SIGN_ PORTS in makefile)
	SIGNERS="${SIGNERS}" API_PORTS="${API_PORTS}" $(call ANSIPLAY, install-firewall.yaml)
	SERVERS="${SERVERS}" SIGN_PORTS="${SIGN_PORTS}" $(call ANSIPLAY, install-firewall-signers.yaml)

create-accounts: inventory ## create accounts on all servers
	$(call ANSIPLAY, create-accounts.yaml)

install-explorer: inventory ## install the block explorer on the api node
	$(call ANSIPLAY, install-explorer.yaml)

install-faucet: inventory ## install the faucet on the api node
	$(call ANSIPLAY, install-faucet.yaml)

install-promtail: inventory ## install the block explorer on the api node
	$(call ANSIPLAY, install-promtail.yaml)

server-list: ## print a list of servers and their status
	@hcloud server list -o columns=name,status,ipv4,datacenter

ssh: HOST ?= api
ssh: LOGIN ?= app
ssh: ## open an ssh session on HOST=name (see make server-list)
	@ssh $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/${HOST}/{print $$2}') \
	 -l ${LOGIN} -i ./sshkey -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes

server-cmd: CMD ?= describe
server-cmd: ## execute an hcloud server command on all nodes
	./hcloud-server-foreach.sh ${CMD}

list-uptimes: inventory ## list all server uptimes
	$(call ANSIPLAY, list-uptimes.yaml)

