#!/usr/bin/env bash
HOST="http://test.fabchain.net:8545"
ZENROOM_URL="https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64"
Z=./zenroom
MYADDR="28c44EeA27c304bE7416a220515A823E29a0Fb83"
MYSK="2bb7018d08990874cea523d52642ecd470021a4e7d8b93553bbfcd2343ee8b37"

if [ ! -f "$Z" ]; then
  echo "===Download zenroom==="
  curl -X GET $ZENROOM_URL --output zenroom
  chmod +x zenroom
fi


function asknonce() (
    curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionCount","params":["'"$1"'", "latest"],"id":42}' $HOST 2>/dev/null | jq '.result'
    sleep 1
)

function send() (
    curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_sendRawTransaction","params":["'"$1"'"],"id":1}' $HOST 2>/dev/null | jq ".result"
    sleep 1
)

function txreceipt() (
    curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["'"$1"'"],"id":42}' $HOST 2>/dev/null | jq ".result"
    sleep 1
)

function gasprice() (
    curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":42}' $HOST 2>/dev/null | jq ".result"
    sleep 1
)

HEXNONCE=`asknonce "0x$MYADDR" | xargs`
cat <<EOF >store-string.keys
{
  "keys": { "ethereum": "$MYSK" },
  "my_address": "$MYADDR",
  "fabchain": "$HOST",
  "gas limit": "100000",
  "gas price": "`echo "print($(gasprice | xargs))" | python3`",
  "gwei value": "0",
  "storage_contract": "E54c7b475644fBd918cfeDC57b1C9179939921E6",
  "ethereum nonce": "$HEXNONCE",
  "data": "Nel mezzo del cammin di nostra vita\nmi ritrovai per una selva oscura,\nché la diritta via era smarrita."
}
EOF

cat <<EOF >store-string.zen
Rule unknown ignore
Scenario ethereum
Given I have the 'keys'
Given I have a ethereum endpoint named 'fabchain'
Given I have a 'ethereum address' named 'storage contract'
Given I have a 'ethereum nonce'
Given I read the ethereum nonce for 'my_address'
Given I have a 'string' named 'data'
and a 'gas price'
and a 'gas limit'
# Given I read the # ethereum suggested gas price
When I create the ethereum transaction to 'storage contract'
and I use the ethereum transaction to store 'data'

When I create the signed ethereum transaction for chain 'fabt'
Then print the 'signed ethereum transaction'
Then I ask ethereum to broadcast the 'signed_ethereum_transaction' and save the transaction id in 'txid'
Then print data
EOF

RAW=`$Z -z store-string.zen -k store-string.keys 2>/dev/null | jq ".signed_ethereum_transaction" | xargs`
TXID=`send "0x$RAW" | xargs`
sleep 5
for i in $(seq 10); do
  RESULT=`txreceipt "$TXID"`
  if [[ ! $RESULT == "null" ]]; then
    echo "`date -u "+%y/%m/%d_%H:%M:%S_%Z"`;$((5+10*i))"
    exit 0
  fi
  echo $RESULT
  sleep 10
done
echo "`date -u "+%y/%m/%d_%H:%M:%S_%Z"`;ERROR"
exit -1
