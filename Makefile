
VERSION ?= latest

build:
	docker build -t dyne/dyneth:${VERSION} -f Dockerfile .

run:
	docker run -it dyne/dyneth:${VERSION}

shell:
	./scripts/shell.sh
