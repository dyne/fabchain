#!/bin/bash

echo "Installing Docker"
bash ./apt.sh install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list
bash apt.sh update
bash apt.sh install docker-ce docker-ce-cli containerd.io
