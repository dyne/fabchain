# Devops Makefile Operations

```
Usage:
  make <target>[-steps] (play target or just show its -steps)

General
  help             Display this help.
  ssh-keygen       generate a dedicated ssh keypair here

Application management
  start            start all applications
  delete-blockchain  delete blockchain data
  start-signers    start all signers
  start-apis       start all apis
  stop             stop all applications
  upgrade          upgrade all applications to latest container tag
  remote-exec      execute a geth console command on all signers
  remote-shell     execute a shell command on all signers
  remote-copy      upload a file on all nodes

Treasury management
  send-funds       Send an amount of funds from each signer to an address (default 1 to API)

Genesis management
  list-addresses   list all app public addressess
  init-genesis     initialize genesis on all nodes
  init-bootnodes   generate bootnodes from signer ENR addresses
  update-bootnodes  generate bootnodes from signer ENR addresses
  upload-bootnodes  upload bootnodes.csv (used by init-bootnodes)

Server management
  list-datacenters  list all available datacenters
  server-create    create all servers on hcloud, 3 signers and 1 api
  inventory        create an ansible inventory (used internally)
  install          install all servers
  install-firewall  setup firewall rules on all nodes (API_ and SIGN_ PORTS in makefile)
  create-accounts  create accounts on all servers
  create-bootnodes  create current list of bootnodes
  install-explorer  install the block explorer on the api node
  install-faucet   install the faucet on the api node
  install-promtail  install the block explorer on the api node
  server-list      print a list of servers and their status
  ssh              open an ssh session on HOST=name (see make server-list)
  server-cmd       execute an hcloud server command on all nodes
  list-uptimes     list all server uptimes
```
