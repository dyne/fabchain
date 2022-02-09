
all:
	docker build -t dyne/dyneth:${VERSION} \
	 --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
	 --build-arg GETH_VERSION=${GETH_VERSION} \
	 --build-arg SOLC_VERSION=${SOLC_VERSION} \
	 --build-arg VERSION=${VERSION} --build-arg NETWORK_ID=${NETWORK_ID} \
	 --build-arg P2P_PORT=${P2P_PORT} --build-arg API_PORT=${API_PORT} \
	 -f ./Dockerfile .
