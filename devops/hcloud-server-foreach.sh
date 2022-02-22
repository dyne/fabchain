#!/bin/bash

servers=(`hcloud server list -o noheader -o columns=id`)
for s in ${servers[@]}; do
    echo >&2 "hcloud server $* ${s}"
    hcloud server $* ${s}
done
