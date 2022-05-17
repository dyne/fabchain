#!/bin/sh

if [ "$1" == "" ]; then
    echo "usage: $0 network_name signers"
    echo "the signers all the addresses separated by a ,"
    exit 1
fi

network_id=`echo "print(INT.new(O.new(\"$1\")):decimal())" | zenroom`
signers=`echo "$2" | sed 's/\([0-9a-zA-Z]*\)/\"\1\"/g'`
cat <<EOF
{
  "signers": [ $signers ],
  "epoch": "`date +'%s'`",
  "period": 7,
  "gaslimit": 31000000,
  "share": "100000000000000000000000000000",
  "chainid": $network_id
}
EOF
