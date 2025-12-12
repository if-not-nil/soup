#!/usr/bin/env bash

declare -a cmds=(
	"cc -Wall --std=c23 ./asdf.c -o /tmp/soup_test"
	"/tmp/soup_test"
)

for cmd in "${cmds[@]}"; do
	echo "\$ $cmd"
	err=""
	$cmd
	if [ "$?" != 0 ]; then
		echo "error: command $cmd failed with code $?"
		exit $?
	fi
done
