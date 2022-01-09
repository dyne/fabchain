include ../config.mk
export

all:
	docker build -t ghcr.io/dyne/dyneth:${VERSION} \
	 --build-arg VERSION=${VERSION} --build-arg NETWORK_ID=${NETWORK_ID} \
	 --build-arg P2P_PORT=${P2P_PORT} --build-arg API_PORT=${API_PORT} \
	 -f ./Dockerfile .
