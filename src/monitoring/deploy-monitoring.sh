#!/bin/bash

#####################################################################################
# Ensure that the pre-requisites and environment variables for login 
# usernames/passwords are set
#####################################################################################
#if [ -z $MONITORING_USERNAME ]; then
#    echo "Need to set environment variable MONITORING_USERNAME before deploying monitoring tools"
#    exit
#fi
MONITORING_USERNAME=admin

if [ -z $MONITORING_PASSWORD ]; then
    echo "Need to set environment variable MONITORING_PASSWORD before deploying monitoring tools"
    exit
fi

#####################################################################################
# Deploy the monitoring services.  Ensure that telegraf has a container on each node
#####################################################################################

# Get the number of agent nodes
echo -n "Checking for agent node count : "
NODE_COUNT=`docker info 2>/dev/null | grep swarm-agent | wc -l`
echo "${NODE_COUNT} agent nodes"

# Build the monitoring containers
cd influxdb
./build.sh
cd ../

cd host
./build.sh
cd ../

# Deploy the monitoring solution
echo "Pulling containers.."
docker-compose pull 
echo "Creating containers.."
docker-compose create
echo "Starting containers.."
docker-compose start
echo "Scaling telegraf agent monitor to all nodes.."
docker-compose scale telegrafhost=$NODE_COUNT

#####################################################################################
# Import the grafana dashboards and data sources
#####################################################################################
# Update the grafana password
# curl -X PUT -H "Content-Type: application/json" -d '{
#   "oldPassword": "admin",
#   "newPassword": "${MONITORING_PASSWORD}",
#   "confirmNew": "${MONITORING_PASSWORD}"
# }' http://admin:admin@localhost:3000/api/user/password

# echo "Installing wizzy tool and prerequisites for managing grafana"
# sudo apt-get update
# sudo apt-get install npm
# sudo npm install -g wizzy

# cd grafana-dashboards
# wizzy init

# wizzy set grafana envs demo url http://{$DEMO_AGENT_FQDN}:3000
# wizzy set grafana envs demo username $MONITORING_USERNAME
# wizzy set grafana envs demo password $MONTIORING_PASSWORD
# wizzy set context demo

# # Export == export from wizzy to grafana
# wizzy export datasources
# wizzy export dashboards
