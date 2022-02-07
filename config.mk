# DYNETH configuration

VERSION := latest@sha256:b6d4cf06610afc35727d9c187a1e6855a6d99ae7b3b0409c9730cf44a393e2e0 
DOCKER := ghcr.io/dyne/dyneth
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
