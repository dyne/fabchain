# DYNETH configuration

VERSION := latest@sha256:40740bcf719b0e00d250cb9a3711701642c016fb9f6d673bd201e32beec14c04
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
