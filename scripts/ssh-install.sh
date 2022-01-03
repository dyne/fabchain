#!/usr/bin/env bash

H="$1"
[[ "$H" == "" ]] && {
	echo "Usage: ./setup.sh ssh@host.online.net"
	return 1
}

debver=`ssh $H cat /etc/debian_version`
echo "Detected Debian version: $debver"
ssh $H 'printf "#!/bin/bash\nDEBIAN_FRONTEND="noninteractive" apt-get -q -y \$*\n" >apt.sh'
ssh $H bash ./apt.sh update

echo "Installing Docker"
scp ./scripts/docker-install.sh $H:
ssh $H bash docker-install.sh

echo "Installing Zenroom"
ssh $H curl -o /usr/local/bin/zenroom \
    https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 
ssh $H chmod +x /usr/local/bin/zenroom

echo "Installing git and make"
ssh $H bash ./apt.sh install git make

echo "Installation completed, please reboot $H"
