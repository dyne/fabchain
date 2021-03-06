#!/bin/bash

set -e
# Deploy a contract given the solidity script on a network

. scripts/host-lib.sh

contract="$1"
params="$2"
gas_price="$3"
gas_limit="$4"
sk=`secret_key`

cat <<EOF
from web3 import Web3, HTTPProvider

abi = None
bin = None

with open('/contracts/build/$contract.abi') as file:
  abi = file.read()

with open('/contracts/build/$contract.bin') as file:
  bin = file.read()

if not abi or not bin:
  print("Error while reading abi or bin")
  exit(-1)

sk = "$sk"

w3 = Web3(HTTPProvider('http://127.0.0.1:8545'))
account = w3.eth.account.privateKeyToAccount(sk)

my_contract = w3.eth.contract(abi=abi, bytecode=bin)
construct_txn = my_contract.constructor($params).buildTransaction({
    'from': account.address,
    'nonce': w3.eth.getTransactionCount(account.address),
    'gas': ${gas_limit},
    'gasPrice': ${gas_price}})

signed = account.signTransaction(construct_txn)

txid=w3.eth.sendRawTransaction(signed.rawTransaction).hex()

print("{}".format(txid))
EOF
