help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile


current-ts: ## Check progress (when you run `make run`)
	@redis-cli get "logcli:timestamp"

run: ## Collect connections
	@bash -c ". ./init.sh && lua ./readUntilNow.lua"

result: ## Show results
	@redis-cli hgetall "logcli:connections"
