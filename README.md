```
░█▀▄░█░█░█▀█░█▀▀░▀█▀░█░█
░█░█░░█░░█░█░█▀▀░░█░░█▀█
░▀▀░░░▀░░▀░▀░▀▀▀░░▀░░▀░▀
```

<p align="center">
  <a href="https://hub.docker.com/r/dyne/dyneth/">
    <img src="https://github.com/dyne/dyneth/actions/workflows/publish-x86.yml/badge.svg" alt="Docker build Status" />
  </a>
  <a href="https://dyne.org">
    <img src="https://img.shields.io/badge/%3C%2F%3E%20with%20%E2%9D%A4%20by-Dyne.org-blue.svg" alt="Dyne.org" />
  </a>
</p>

<a href="https://dyne.org">
</a>

<h4 align="center">
  <a href="#-install">💾 Install</a>
  <span> • </span>
  <a href="#-quick-start">🎮 Quick start</a>
  <span> • </span>
  <a href="#-api">🐝 API</a>
  <span> • </span>
  <a href="#-configuration">🔧 Configuration</a>
  <span> • </span>
  <a href="#-acknowledgements">😍 Acknowledgements</a>
  <span> • </span>
  <a href="#-license">💼 License</a>
</h4>

Bloat-free toolbox to create and operate new blockchains based on ethereum technology using [geth](https://geth.ethereum.org/). Dyneth is fully cross-platform and facilitates operations on nodes using the command-line: one can use it to compile and deploy smart contracts as well easily build public web interfaces to contract operations using [Zenroom](https://zenroom.org).

Dyneth is optimized to run with bare-bone ethereum tools:
- there is no javascript or nodejs involved
- runs everywhere inside a minimal Alpine GNU/Linux docker
- geth is natively compiled from its golang source
- solc is natively compiled from its C++ source
- interaction is designed via shell scripts and makefiles

<details id="toc">
 <summary><strong>🚩 Table of Contents</strong> (click to expand)</summary>

* [Install](#-install)
* [Quick start](#-quick-start)
* [Docker](#-docker)
* [API](#-api)
* [Configuration](#-configuration)
* [Acknowledgements](#-acknowledgements)
* [License](#-license)
</details>

***
## 💾 Install

This application is made to work on Apple/OSX, Microsoft/WSL or
GNU/Linux desktop systems. The host system needs the following
dependencies installed:

- Make, awk, bash, find, curl (found pretty much everywhere)
- Docker - http://docker.com (from website, don't use distro packages)
- upnpc - http://miniupnp.tuxfamily.org (optional, to automatically open port forwarding)
- Python3, pip and web3 (optional, to extract private keys for other wallets)

**[🔝 back to top](#toc)**

***
## 🎮 Quick start

Dyneth is operated from a terminal inside its folder, all commands are
issued by the Makefile and therefore prefixed by `make`.

Starting dyneth will result in a JSON-RPC API interface available on localhost:8545.

To start using dyneth just clone this repo, enter it and issue the command `make run`.

It will start a light node connected to our testnet (network ID 1146703429).

To access the Alpine system running in docker use `make shell`

To access the geth console running use `make console`.

To stop issue the command `make stop`.

A full overview of commands is shown simply typing `make`:

```
Server commands:
 make run - start the API node listening on HTTP
 make shell - open a shell inside running server (CMD=sh or custom)
 make status - see if server is running and print public address
 make stop - stop running server

Account commands:
 make account - create a new private account in ~/.dyneth/keystore
 make backup  - prints the private account contents as JSON string
 make restore - asks for private account string to restore from backup
 make run-signer - start the SIGNER node with current account

Development commands:
 make debug - run a shell in a new interactive container (no daemons)
 make build - build the local ./Dockerfile as dyne/dyneth:VERSION
```
**[🔝 back to top](#toc)**


***
## 🔧 Configuration

User-facing configurations are set in [config.mk](config.mk)

Defaults are made to work with dyneth permissioned testnet.

To change the ethereum network connected edit `NETWORK_ID` inside this file.

***
## 🐝 API

Dyneth uses the official ethereum go client to provide full access to
the latest API specifications for the namespaces `eth` and `web3`
available on nodes connecting port 8545 via HTTP.

API documentation is maintained by the ethereum project:
- [Latest Ethereum JSON-RPC Specification](https://playground.open-rpc.org/?schemaUrl=https://raw.githubusercontent.com/ethereum/eth1.0-apis/assembled-spec/openrpc.json&uiSchema%5BappBar%5D%5Bui:splitView%5D=false&uiSchema%5BappBar%5D%5Bui:input%5D=false&uiSchema%5BappBar%5D%5Bui:examplesDropdown%5D=false)
- https://eth.wiki/json-rpc/API (wiki documentation)
- https://geth.ethereum.org/docs/rpc/ns-eth (main namespace)
- https://geth.ethereum.org/docs/rpc/ns-clique (administration of permissioned chains)
- https://geth.ethereum.org/docs/rpc/ns-miner (signing transactions)

**[🔝 back to top](#toc)**


***
## 🌞 GENESIS

To bootstrap a new blokchain one needs to create a genesis, which
needs a new chainID which is an integer, easy to find using a string
for instance `fabt` we do:
```
echo "print(BIG.new(O.from_string('fabt')):decimal())" | zenroom
```
And find `1717658228` as our 4 letter chain ID.

Then copy
[scripts/params-genesis.json.example](scripts/params-genesis.json.example)
to a new file `scripts/params-genesis.json` and configure it with the
chain IDs, the current epoch and other base configurations as for
instance the `share` of coins assigned to each signer, which is in
fact the total amount of coins pre-mined.

Then install all the new signer nodes, create their accounts and note
down their addressess, using our [devops](devops) setup that is simply
made with:

```
cd devops
make server-create    # creates 3 signers and 1 api server
make install          # instals all servers with dyneth
make list-addressess
cd -
```

Then fill the signer addressess in the `scripts/params-genesis.json`
and run `make genesis-create` and the genesis will be found in
`data/genesis.json` ready for your local node.

Then if using the [devops](devops) tools to create the nodes:

```
cp data/genesis.json devops/
cd devops
make init-genesis
make init-bootnodes
cd -
```

Both `genesis.json` and `bootnodes.csv` need to be uploaded on
each new node for the network to function.

**[🔝 back to top](#toc)**


***
## 😍 Acknowledgements

[![software by Dyne.org](https://files.dyne.org/software_by_dyne.png)](http://www.dyne.org)

Dyneth is Copyright (C) 2022 by [Dyne.org](https://www.dyne.org) foundation

Designed, written and maintained by Denis Roio and Puria Nafisi Azizi

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
    
This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.
    
You should have received a copy of the GNU Affero General Public
License along with this program.  If not, see
<http://www.gnu.org/licenses/>.

**[🔝 back to top](#toc)**


***
## 💼 License
    {project_name} - {tagline}
    Copyleft (ɔ) 2021 Dyne.org foundation, Amsterdam

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

**[🔝 back to top](#toc)**

