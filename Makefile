
VERSION ?= latest
HOME ?= $(shell pwd)

all:
	@echo "make pull  - download the stable dyne/dyneth docker image"
	@echo "make account - create a new private account in ~/.dyneth/keystore"
	@echo "make run   - run the local dyne/dyneth docker image"
	@echo "make build - build the local ./Dockerfile as dyne/dyneth:latest"

build:
	docker build -t dyne/dyneth:${VERSION} -f Dockerfile .

run:
	bash ./scripts/run.sh

shell:
	bash ./scripts/shell.sh

account:
	@bash ./scripts/account.sh new

backup:
	@bash ./scripts/account.sh backup

restore:
	@bash ./scripts/account.sh restore
