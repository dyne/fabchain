
VERSION ?= latest
HOME ?= $(shell pwd)

all:
	@echo "Server commands:" ;\
	 echo " make run - start the dyneth server as full node listening on 30303" ;\
	 echo " make shell - open a shell inside running server (CMD=bash or custom)" ;\
	 echo " make status - see if dyneth server is running and print public address" ;\
	 echo " make stop - stop running server" ;\
	 echo
	@echo "Account commands:" ;\
	 echo " make account - create a new private account in ~/.dyneth/keystore" ;\
	 echo " make backup  - prints the private account contents as JSON string" ;\
	 echo " make restore - asks for private account string to restore from backup" ;\
	 echo
	@echo "Development commands:" ;\
	 echo " make build - build the local ./Dockerfile as dyne/dyneth:latest" ;\
	 echo

init:
	@sh ./scripts/motd

build:
	docker build -t dyne/dyneth:${VERSION} -f devops/Dockerfile.api .

build-signer:
	docker build -t dyne/dyneth-signer:${VERSION} -f Dockerfile .

run:	init
run:	container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
run:
	@if [ "x${container}" = "x" ]; then \
		echo "Launching docker container for the HTTP API server:" ;\
		docker run -d -p 30303:30303/tcp -p 30303:30303/udp -p 8545:8545 \
		dyne/dyneth ;\
	else \
		echo "Already running in docker container: ${container}" ;\
	fi
	@echo "P2P networking through port 30303"
	@echo "HTTP API available at port 8545"
	@echo "run 'make shell' for an interactive console" && echo

console: init
console: container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
console:
	@if [ "x${container}" = "x" ]; then \
		echo "Container is not running" && echo ;\
	else \
		echo "Dyneth console starting" && echo ;\
		docker exec -it ${container} geth attach /var/lib/dyneth/geth.ipc ;\
		echo ;\
	fi

stop:	init
stop:	container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
stop:
	@if [ "x${container}" = "x" ]; then \
		echo "Container is not running" && echo ;\
	else \
		echo "Stopping container:" ;\
		docker container stop ${container} ;\
		echo ;\
	fi

shell:	init
shell:	container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
shell:	CMD ?= "sh"
shell:
	@if [ "x${container}" = "x" ]; then \
		echo "Container is not running" && echo ;\
	else \
		echo "Container running: ${container}" ;\
		echo "Executing command: ${CMD}" && echo ;\
		docker exec -it ${container} ${CMD} ;\
		echo && echo "Command executed: ${CMD}" && echo ;\
	fi

log: init
log: container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
log:
	@if [ "x${container}" = "x" ]; then \
		echo "Container is not running" && echo ;\
	else \
		echo "Container running: ${container}" ;\
		docker exec -it ${container} cat /var/lib/dyneth/log/* ;\
	fi

# SIGNER

run-signer: init
run-signer: container := $(shell docker container ls|awk '/dyne\/dyneth/ { print $$1 }')
run-signer:
	@if [ "x${container}" = "x" ]; then \
		echo "Launching docker container for the SIGNER server:" ;\
		docker run -d -p 30303:30303/tcp -p 30303:30303/udp \
		--mount type=bind,source=${HOME}/.dyneth,destination=/var/lib/dyneth \
		dyne/dyneth supervisord -c /etc/supervisor/supervisord.conf -n ;\
	else \
		echo "Already running in docker container: ${container}" ;\
	fi
	@echo "P2P networking through port 30303"
	@echo "Data storage in ~/.dyneth" && echo
	@echo "run 'make shell' for an interactive console" && echo

account: init
	@bash ./scripts/account.sh new

backup: init
	@bash ./scripts/account.sh backup

restore: init
	@bash ./scripts/account.sh restore

status: init
status: container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
status:
	@if [ "x${container}" = "x" ]; then \
		echo "Status: NOT RUNNING" && echo ;\
	else \
		echo "Status: RUNNING" && echo ;\
	fi


# DEBUG and LOG

debug:	init
debug:	container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
debug:
	@echo "P2P networking through port 30303"
	@echo "HTTP API available at port 8545"
	@echo "Data storage in ~/.dyneth" && echo
	@if [ "x${container}" = "x" ]; then \
		echo "Debugging docker container:" ;\
		docker run -it -p 30303:30303/tcp -p 30303:30303/udp -p 8545:8545 \
		--mount type=bind,source=${HOME}/.dyneth,destination=/var/lib/dyneth \
		dyne/dyneth bash ;\
	else \
		echo "Already running in docker container: ${container}" ;\
	fi

log.supervisor: init
log.supervisor:
	tail -n 2000 ${HOME}/.dyneth/log/supervisord.log
