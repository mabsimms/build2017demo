#!/bin/bash

#####################################################################################
# Deploy the monitoring services.  Ensure that telegraf has a container on each node
#####################################################################################

# Get the number of agent nodes
NODE_COUNT=`docker info 2>/dev/null | grep swarm-agent | wc -l`

# Deploy the monitoring solution
echo "Creating containers.."
docker-compose create
echo "Starting containers.."
docker-compose start
echo "Scaling telegraf agent monitor to all nodes.."
docker-compose scale telegraf=$NODE_COUNT

# Import the grafana dashboards and data sources

