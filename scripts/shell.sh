#!/bin/sh

# opens a shell in a running dyneth docker

c=$(docker container ls | awk '/dyne\/dyneth/ { print $1 }')
if [ "$c" = "" ]; then return 1; fi
if [ "$1" = "" ]; then
	docker exec -it $c bash
else
	docker exec -it $c $*
fi
