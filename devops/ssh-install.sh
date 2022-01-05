#!/usr/bin/env bash
#
# simple provisioning script for Debian/Ubuntu remote host

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
tmp=`mktemp`
cat <<EOF > $tmp
echo "Installing Docker"
bash ./apt.sh install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list
bash apt.sh update
bash apt.sh install docker-ce docker-ce-cli containerd.io
EOF
scp $tmp $H:docker-install.sh
rm -f $tmp
ssh $H bash docker-install.sh

echo "Installing Zenroom"
ssh $H curl -o /usr/local/bin/zenroom \
    https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 
ssh $H chmod +x /usr/local/bin/zenroom

echo "Installing git and make"
ssh $H bash ./apt.sh install git make

echo "Installation completed, please reboot $H"
