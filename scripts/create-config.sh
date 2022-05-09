#!/usr/bin/env bash
network=$2
port=$3
port_p2p=$4

. scripts/host-lib.sh

## parse bootnodes enode
bootnodes_csv="devops/bootnodes.csv"
bootnodes=""
if [ -r "$bootnodes_csv" ]; then
    while read i; do
	if ! [ "$bootnodes" == "" ]; then bootnodes="${bootnodes},"; fi
	bootnodes="${bootnodes}\"$(echo $i)\""
    done < $bootnodes_csv
fi
echo "Bootnodes: $bootnodes"

network_id="`echo "print(INT.new(O.new(\\\"$network\\\")):decimal())" | zenroom 2>/dev/null`"
case "$1" in
  api) cat <<EOF >data/api.toml
[Eth]
NetworkId = $network_id
SyncMode = "snap"

[Node]
DataDir = "/home/geth/.ethereum"
IPCPath = "geth.ipc"
HTTPHost = "0.0.0.0"
HTTPPort = $port
HTTPVirtualHosts = ["*"]
HTTPCors = ["*"]
HTTPModules = ["net", "web3", "eth", "personal"]
WSOrigins = ["*"]
WSHost = "0.0.0.0"

[Node.P2P]
ListenAddr = ":$port_p2p"
NoDiscovery = true
BootstrapNodes = [$bootnodes]
BootstrapNodesV5 = [$bootnodes]
StaticNodes = [$bootnodes]
TrustedNodes = [$bootnodes]
EOF
  ;;
  sign) cat <<EOF >data/sign.toml
[Eth]
NetworkId = $network_id
SyncMode = "full"

[Node]
DataDir = "/home/geth/.ethereum"
IPCPath = "geth.ipc"

[Node.P2P]
ListenAddr = ":$port_p2p"
NoDiscovery = true
BootstrapNodes = [$bootnodes]
BootstrapNodesV5 = [$bootnodes]
StaticNodes = [$bootnodes]
TrustedNodes = [$bootnodes]
EOF
  ;;
esac
