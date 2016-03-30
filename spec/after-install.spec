#!/bin/bash

if [ "${1}" = 1 ]; then
	useradd -M consul > /dev/null 2>&1
	mkdir -p /var/consul > /dev/null 2>&1
	chown consul:consul /var/consul/ > /dev/null 2>&1
	chkconfig --add consul > /dev/null 2>&1
fi
