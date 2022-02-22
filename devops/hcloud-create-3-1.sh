#!/bin/bash

## TODO: create 3 signers and 1 api servers
## call them fabchain-sign and fabchain-api

DATACENTERS=(${1})
echo >&2 "Datacenters: ${DATACENTERS[@]}"

image=debian-11
srvtype=cx11

# create 3 signers
c=1
for i in ${DATACENTERS[@]}; do

    echo >&2 "hcloud server create --name sign-${c} --image ${image} --datacenter ${i} --type ${srvtype} --ssh-key ./sshkey.pub"
    hcloud server create --name sign-${c} --image ${image} --datacenter ${i} --type ${srvtype} --ssh-key ./sshkey.pub
    c=$(( $c + 1 ))

done

# create 1 api
echo >&2 "hcloud server create --name api --image ${image} --datacenter ${DATACENTERS[0]} --type ${srvtype} --ssh-key ./sshkey.pub"
hcloud server create --name api --image ${image} --datacenter ${i} --type ${srvtype} --ssh-key ./sshkey.pub

# delete new servers from ssh cache
ips=(`hcloud server list -o noheader -o columns=ipv4`)

for i in ${ips[@]}; do
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "${i}"
done
