#!/bin/bash

if [ "${1}" = 0 ]; then
	service consul stop > /dev/null 2>&1 || true
	chkconfig --del consul > /dev/null 2>&1 || true
fi
