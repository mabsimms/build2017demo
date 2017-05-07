#!/bin/bash

RESOURCE_GROUP=mas-bld-rg

# TODO - ssh to all of the machines and update sysctl for elasticsearch

# Create a shared (global) network for the demo resources
# https://docs.docker.com/engine/userguide/networking/get-started-overlay/#run-an-application-on-your-network
#docker network create --driver overlay --subnet 10.0.5.0/24 build2017-demo-network

# https://docs.microsoft.com/en-us/azure/container-service/container-service-enable-public-access
# Open up the monitoring ports
PORTS=(3000)

# Get the name of the network resources
LB_NAME=`az network lb list --resource-group mas-bld-rg --output table | \
    grep agent | tr -s ' ' | cut -d' ' -f2`
echo "Using load balancer name ${LB_NAME}"

POOL_NAME=`az network lb address-pool list --resource-group mas-bld-rg \
    --lb-name swarm-agent-lb-10FB764F --output table | grep pool | cut -d' ' -f1`
echo "Using back end pool name ${POOL_NAME}"

FRONTEND_NAME=`az network lb frontend-ip list --resource-group mas-bld-rg \
    --lb-name  swarm-agent-lb-10FB764F | jq .[0].name | sed 's/\"//g'`
echo "Using front end name ${FRONTEND_NAME}" 

for PORT in "${PORTS[@]}"
do
    # Create a load balancer probe for this port
    echo "Creating load balancer probe for port ${PORT}"
    az network lb probe create --resource-group ${RESOURCE_GROUP} --protocol Tcp \
        --lb-name ${LB_NAME} --name probe${PORT} --port ${PORT} 

    # Create a load balancing rule for this port
    echo "Creating load balancer rule for port ${PORT}"
    az network lb rule create --resource-group ${RESOURCE_GROUP} \
        --protocol Tcp --lb-name ${LB_NAME} \
        --name Allow${PORT} \
        --backend-pool-name $POOL_NAME \
        --frontend-ip-name $FRONTEND_NAME \
        --probe-name probe${PORT} \
        --frontend-port ${PORT} \
        --backend-port ${PORT} 

    # Create an NSG rule to allow traffic inbound on this port
    # TODO
done
