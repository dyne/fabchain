```
░█▀▄░█░█░█▀█░█▀▀░▀█▀░█░█
░█░█░░█░░█░█░█▀▀░░█░░█▀█
░▀▀░░░▀░░▀░▀░▀▀▀░░▀░░▀░▀
```

# Usage

Dyneth is operated from a terminal inside its folder, all commands are
issued by the Makefile and therefore prefixed by `make`

```
Server commands:
 make run - start the API node listening on HTTP port 8545
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
 make build - build the local ./Dockerfile as dyne/dyneth:latest
```

# Requirements

This application is made to work on Apple/OSX, Microsoft/WSL or
GNU/Linux desktop systems. Needs the following dependencies:

- Awk, bash, sh, find, curl
- Docker - http://docker.com
- upnpc - http://miniupnp.tuxfamily.org

# Acknowledgements

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
