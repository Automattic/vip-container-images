#!/bin/sh

cd /shared || exit

while true; do
	git fetch
	head=$(git rev-parse HEAD)
	master=$(git rev-parse origin/master)
	if [ "$head" != "$master" ]; then
		git reset --hard origin/master
		git submodule update
	fi
	sleep 60
done