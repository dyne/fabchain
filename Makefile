
VERSION ?= latest
HOME ?= $(shell pwd)

all:
	@echo "make pull  - download the stable dyne/dyneth docker image"
	@echo "make account - create a new private account in ~/.dyneth/keystore"
	@echo "make run   - run the local dyne/dyneth docker image"
	@echo "make build - build the local ./Dockerfile as dyne/dyneth:latest"

build:
	docker build -t dyne/dyneth:${VERSION} -f Dockerfile .

run:	container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
run:
	@sh ./scripts/motd
	@if [ "x${container}" = "x" ]; then \
		echo "Launching docker container:" ;\
		docker run -d -p 30303:30303/tcp -p 30303:30303/udp \
		--mount type=bind,source=${HOME}/.dyneth,destination=/var/lib/dyneth \
		dyne/dyneth supervisord -c /etc/supervisor/supervisord.conf ;\
	else \
		echo "Already running in docker container: ${container}" ;\
	fi
	@echo "P2P networking through port 30303"
	@echo "Data storage in ~/.dyneth" && echo
	@echo "run 'make shell' for an interactive console" && echo

stop:	container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
stop:
	@sh ./scripts/motd
	@if [ "x${container}" = "x" ]; then \
		echo "Container is not running" && echo ;\
	else \
		echo "Stopping container:" ;\
		docker container stop ${container} ;\
		echo ;\
	fi

shell: container := $(shell docker container ls | awk '/dyne\/dyneth/ { print $$1 }')
shell: CMD ?= "bash"
shell:
	@sh ./scripts/motd
	@if [ "x${container}" = "x" ]; then \
		echo "Container is not running" && echo ;\
	else \
		echo "Container running: ${container}" ;\
		echo "Executing command: ${CMD}" && echo ;\
		docker exec -it ${container} ${CMD} ;\
		echo && echo "Command executed: ${CMD}" && echo ;\
	fi

account:
	@bash ./scripts/account.sh new

address:
	@bash ./scripts/account.sh address

backup:
	@bash ./scripts/account.sh backup

restore:
	@bash ./scripts/account.sh restore
