#!/bin/bash

mkdir /tmp/wrk2-install
cd /tmp/wrk2-install

sudo apt-get install build-essential libssl-dev git
git clone https://github.com/giltene/wrk2.git
cd wrk2
make

# move the executable to somewhere in your PATH
sudo cp wrk /usr/local/bin
