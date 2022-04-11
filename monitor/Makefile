R ?= $(realpath ..)
CONFIG ?= testnet
include ../${CONFIG}.mk

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>[-steps] (play target or just show its -steps)\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

graph-dot: ## generate a grapviz dot file with the current peer network graph
	hcloud server list -o noheader -o columns=name,status,ipv4,datacenter > server_names.txt
	rm -f server_peers.txt && touch server_peers.txt
	for i in `awk '{print $$1}' server_names.txt`; do \
	  make -C ${R}/devops remote-exec ON=$$i CMD=admin.peers | \
	  awk '/^make/{next} {print $$0}' >> server_peers.txt; \
	done
#	zenroom servers2dot.lua -k server_peers.txt -a servers_names.txt
