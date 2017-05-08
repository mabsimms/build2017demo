#!/bin/bash


################################################################################################
# https://docs.microsoft.com/en-us/azure/container-service/container-service-enable-public-access
# Open up the monitoring ports; note - this is not a recommended production approach.  Would be 
# better to install an nginx/haproxy specifically for the mgmt services and route traffic through
# there
PORTS=(3000 5601)

# Get the name of the network resources
LB_NAME=`az network lb list --resource-group ${DEMO_RESOURCE_GROUP} --output table | \
    grep agent | tr -s ' ' | cut -d' ' -f2`
echo "Using load balancer name ${LB_NAME}"

POOL_NAME=`az network lb address-pool list --resource-group ${DEMO_RESOURCE_GROUP}  \
    --lb-name ${LB_NAME} --output table | grep pool | cut -d' ' -f1`
echo "Using back end pool name ${POOL_NAME}"

FRONTEND_NAME=`az network lb frontend-ip list --resource-group ${DEMO_RESOURCE_GROUP} \
    --lb-name ${LB_NAME} | jq .[0].name | tr -d '"'`
echo "Using front end name ${FRONTEND_NAME}" 

for PORT in "${PORTS[@]}"
do
    # Create a load balancer probe for this port
    echo "Creating load balancer probe for port ${PORT}"
    az network lb probe create --resource-group ${DEMO_RESOURCE_GROUP} --protocol Tcp \
        --lb-name ${LB_NAME} --name probe${PORT} --port ${PORT} 

    # Create a load balancing rule for this port
    echo "Creating load balancer rule for port ${PORT}"
    az network lb rule create --resource-group ${DEMO_RESOURCE_GROUP} \
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
