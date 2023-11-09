#!/bin/bash

pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
sleep 10
conky -c ./conky.conf &
sleep 1
disown -a
exit 0
