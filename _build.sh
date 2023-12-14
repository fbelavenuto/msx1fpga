#!/usr/bin/env bash

set -e

echo Updating docker image
docker pull fbelavenuto/8bitcompilers
docker pull fbelavenuto/xilinxise
docker pull fbelavenuto/alteraquartus

echo Building software
docker run --rm -it -e TZ=America/Sao_Paulo -v $PWD:/src fbelavenuto/8bitcompilers make -f Makefile-software

mkdir -p _BINs

echo Building Xilinx FPGA bitstreams
docker run --rm -it --mac-address 08:00:27:68:c9:35 -e TZ=America/Sao_Paulo -v $PWD:/workdir fbelavenuto/xilinxise make -f Makefile-xilinx

echo Building Altera FPGA bitstreams
docker run --rm -it --mac-address 00:01:02:03:04:05 -e TZ=America/Sao_Paulo -v $PWD:/workdir fbelavenuto/alteraquartus make -f Makefile-altera

