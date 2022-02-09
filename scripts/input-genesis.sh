#!/bin/sh

if [ "$1" == "" ]; then
    echo "usage: $0 network_id"
    exit 1
fi

cat <<EOF
{
  "signers": [ "INSERT", "SIGNERS", "HERE" ],
  "epoch": "`date +'%s'`",
  "period": 7,
  "gaslimit": 31000000,
  "share": 1048576,
  "chainid": $1
}
EOF
