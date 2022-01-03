#!/bin/sh

# set it to somewhere in the home
src=$HOME/.dyneth
mkdir -p "$src"/data
mkdir -p "$src"/keys
mkdir -p "$src"/log

touch $src/.keep || exit 1

bash ./scripts/motd

# prompt
# ⓓⓨⓝⓔⓣⓗ

cat <<EOF

open another terminal and run:
- make shell - for an interactive console inside the dyneth docker

Hit Ctrl-C to stop

EOF

docker run -it \
       --mount type=bind,source="$src",destination=/var/lib/dyneth \
       dyne/dyneth:latest
