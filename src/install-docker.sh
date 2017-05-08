#!/bin/bash

# Need at least docker v1.13 and above (default ubuntu docker.io apt get is 1.12)
sudo apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

sudo apt-get update
sudo apt-get -y install docker-ce
sudo docker version

# Update docker-compose installation
curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > ./docker-compose
cp ./docker-compose /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose

sudo pip uninstall docker-py
sudo pip uninstall docker
sudo pip install docker
