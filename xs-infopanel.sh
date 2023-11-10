#!/bin/bash

pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Waiting 10 seconds to avoid potentail crash from starting too soon"
sleep 10
conky -c ./conky.conf &
sleep 1
disown -a
exit 0
