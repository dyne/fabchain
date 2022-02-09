# DYNETH configuration

VERSION := 0.6.0
TAG := $(file <data/hash.tag)
DOCKER := dyne/dyneth
DOCKER_IMAGE := ${DOCKER}:${VERSION}-${TAG}
NETWORK_ID := 1146703429
P2P_PORT := 30303
API_PORT := 8545
DATA := $(shell pwd)/data
CONTRACTS := $(shell pwd)/contracts
GETH_VERSION := 1.10.14
SOLC_VERSION := 0.8.11
ALPINE_VERSION := 3.15

# automatic
UID = $(id -u)
GID = $(id -g)
