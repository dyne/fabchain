#!/usr/bin/env bash
HOST="http://test.fabchain.net:8545"
ZENROOM_URL="https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64"
Z=./zenroom
MYADDR="231C6f2f3a07b309f04fea3d675C8e191276EC9b"
MYSK="f11e5fd92f539e00e005a7d9440a6e48afc79c7dd2512562745a606cb8bfc339"

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
  "keyring": { "ethereum": "$MYSK" },
  "my_address": "$MYADDR",
  "gas limit": "100000",
  "gas price": "`echo "print($(gasprice | xargs))" | python3`",
  "gwei value": "0",
  "storage_contract": "42A998bf52284703deCdCF20d3FE3C8997a6DE26",
  "ethereum nonce": "$HEXNONCE",
  "data": "Nel mezzo del cammin di nostra vita\nmi ritrovai per una selva oscura,\nché la diritta via era smarrita."
}
EOF

cat <<EOF >store-string.zen
Scenario ethereum
Given I have the 'keyring'
Given I have a 'ethereum address' named 'storage contract'
Given I have a 'ethereum nonce'
Given I have a 'string' named 'data'
and a 'gas price'
and a 'gas limit'
When I create the ethereum transaction to 'storage contract'
and I use the ethereum transaction to store 'data'

When I create the signed ethereum transaction for chain 'fabt'
Then print the 'signed ethereum transaction'
Then print data
EOF

RAW=`$Z -z store-string.zen -k store-string.keys 2>/dev/null | jq ".signed_ethereum_transaction" | xargs`
TXID=`send "0x$RAW" | xargs`
sleep 5
for i in $(seq 10); do
  RECEIPT=`txreceipt "$TXID"`
  if [[ ! "$RECEIPT" == "null" && ! "$RECEIPT" == "" ]]; then
    STATUS=`echo $RECEIPT | jq ".status" | xargs`
    LOGS=`echo $RECEIPT | jq ".logs" | xargs`
    if [[ "$STATUS" == "0x1" && ! "$LOGS" == "[]" ]]; then
      echo "`date -u "+%y/%m/%d_%H:%M:%S_%Z"`;$((5+10*i));$TXID"
      exit 0
    elif [[ ! "$STATUS" == "0x1" ]]; then
      echo "`date -u "+%y/%m/%d_%H:%M:%S_%Z"`;FAILED;$TXID"
      exit -1
    else
      echo "`date -u "+%y/%m/%d_%H:%M:%S_%Z"`;NOLOGS;$TXID"
      exit -1
    fi
  fi
  sleep 10
done
echo "`date -u "+%y/%m/%d_%H:%M:%S_%Z"`;ERROR;$TXID"
exit -1
