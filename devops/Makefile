
##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>[-steps] (play target or just show its -steps)\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

steps:
	@cat $(subst -steps,,${MAKECMDGOALS}).yaml | grep '\- name'
play:
	ansible-playbook ${MAKECMDGOALS}.yaml

install: play ## install all nodes with dyneth and its dependencies
install-steps: steps

start: play ## start all nodes (ROLE=sign by default)
start-steps: steps

stop: play ## stop all nodes
stop-steps: steps

upgrade-offline: play ## update all nodes while off-line (no restart)
upgrade-offline-steps: steps

upgrade-restart: play ## update all nodes while on-line (stop-update-start)
upgrade-restart-steps: steps

list-addresses: play ## list all nodes public addressess
list-addresses-steps: steps

list-bootnodes: play ## list all nodes ENR addresses and write data/bootnodes.csv
list-bootnodes-steps: steps
