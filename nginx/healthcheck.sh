#!/usr/bin/env bash

process=$(ps aux | grep nginx | grep -v grep)
if [ "${process}" != "" ]; then
	exit 0
else
	echo 1
fi;
