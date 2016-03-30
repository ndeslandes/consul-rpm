#!/bin/bash

if [ "${1}" = 0 ]; then
	userdel consul > /dev/null 2>&1 || true
fi