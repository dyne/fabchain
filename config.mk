# DYNETH configuration

VERSION := 0.6.0
DOCKER := ghcr.io/dyne/dyneth
NETWORK_ID := 1146703429
P2P_PORT := 30303
API_PORT := 8545
DATA := $(shell pwd)/data

# automatic
UID = $(id -u)
GID = $(id -g)
