#!/bin/bash

# Note: all of the docker-compose files assume the presence of the build2017-demo-network
# global network.  If you change this value you will have to update all of the compose 
# files.
NETWORK_NAME=build2017-demo-network
NETWORK_RANGE=10.0.5.0/24

# Create a shared (global) network for the demo resources
# https://docs.docker.com/engine/userguide/networking/get-started-overlay/#run-an-application-on-your-network
docker network create --driver overlay --subnet ${NETWORK_RANGE} ${NETWORK_NAME} --attachable

# TODO - ssh to all of the machines and update sysctl for elasticsearch
