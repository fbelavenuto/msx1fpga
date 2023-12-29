#!/usr/bin/env bash

set -e

echo Updating docker image
docker pull fbelavenuto/8bitcompilers
docker pull fbelavenuto/xilinxise
docker pull fbelavenuto/alteraquartus
