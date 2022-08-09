#!/bin/sh

cd /shared || exit

while true; do
	git fetch
	head=$(git rev-parse HEAD)
	develop=$(git rev-parse origin/develop)
	if [ "$head" != "$develop" ]; then
		git reset --hard origin/develop
		git submodule update
		rsync -r --delete --exclude-from="/mu-plugins-ext/.dockerignore" /mu-plugins-ext/* ./
	fi
	# 10 mins
	sleep 600
done