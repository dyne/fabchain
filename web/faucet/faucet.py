import datetime
import json
import logging
from decimal import Decimal
# Load env variables
from os import environ

from dotenv import load_dotenv
from flask import Flask, jsonify, request, render_template
from web3 import HTTPProvider, Web3

load_dotenv()

SK = environ.get('SK')
CONTRACT_ADDRESS = environ.get('CONTRACT_ADDRESS')
FAUCET_ABI = json.loads(environ.get('FAUCET_ABI'))
CHAIN_ID = int(environ.get('CHAIN_ID'))
GAS_LIMIT = int(environ.get('GAS_LIMIT'))
GWEI_PRICE = environ.get('GWEI_PRICE')
CLIENT_ADDRESS = environ.get('CLIENT_ADDRESS')

w3 = Web3(HTTPProvider(CLIENT_ADDRESS))
account = w3.eth.account.privateKeyToAccount(SK)

oneEth = Decimal('1000000000000000000')

# Setup logging
logging.basicConfig(filename='faucet.log',
                    level=logging.DEBUG,
                    format='%(asctime)s|%(levelname)s|%(message)s')

# Real web app
app = Flask(__name__)


@app.route("/")
def request_eth():
    balance = Decimal(w3.eth.getBalance(CONTRACT_ADDRESS))
    return render_template('index.html', contract_address = CONTRACT_ADDRESS,
                           balance = balance / oneEth )


@app.route("/faucet")
def faucet_send():
    address = request.args['address']

    if address[0:2] != "0x":
        address = '0x' + address

    address = Web3.toChecksumAddress(address)

    if not Web3.isAddress(address):
        logging.error("{} not an address".format(address))
        return jsonify({'success': False,
                        'error': "{} not an address".format(address)})
    try:
        faucetContract = w3.eth.contract(address=CONTRACT_ADDRESS,
                                         abi=FAUCET_ABI)
        nonce = w3.eth.getTransactionCount(account.address)
        transfer_tx = faucetContract.functions.transfer(address) \
            .buildTransaction({
                'chainId': CHAIN_ID,
                'from': account.address,
                'gas': GAS_LIMIT,
                'gasPrice': w3.toWei(GWEI_PRICE, 'gwei'),
                'nonce': nonce,
            })
        signed = account.signTransaction(transfer_tx)
        txid = w3.eth.sendRawTransaction(signed.rawTransaction).hex()
        with open('addresses.log', 'a') as addresses_log:
            addresses_log.write("{},{},{},{}\n".format(datetime.datetime.now(),
                                                       request.remote_addr,
                                                       address, txid))
        return jsonify({'success': True, 'txid': f'{txid}'})
    except:
        return jsonify({'success': False,
                        'error': 'an error occurred while creating and ' +
                                 'signing the transaction'})
