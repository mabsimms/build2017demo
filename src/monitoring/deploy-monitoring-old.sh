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

# Set the monitoring label on the first node
MON_NODE=`docker node ls | grep agentpublic | sort -k2 | head -1 | tr -s ' ' | cut -d' ' -f2`

SAVEIFS=$IFS
IFS=$'\n'
WRK_NODES=(`docker node ls | grep agentpublic | sort -k2 | tail -n +2 | tr -s ' ' | cut -d' ' -f2 `)
IFS=$SAVEIFS

echo "Setting node $MON_NODE with label role=monitoring"
docker node update $MON_NODE --label-add role=monitoring

for i in "${WRK_NODES[@]}"
do
   echo "Setting node $i with label role=worker"
   docker node update $i --label-add role=worker
done

# Get the number of agent nodes
echo -n "Checking for agent node count : "
NODE_COUNT=`docker node ls | grep -v master | tail -n +2 | wc -l`
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

echo "Starting containers.."
docker stack deploy --compose-file docker-compose.yml monitoring

#####################################################################################
# Import the grafana dashboards and data sources
#####################################################################################

# Update the grafana password
scp update-grafana-dashboard.sh $DEMO_MGMT_FQDN:update-grafana-dashboard.sh
ssh $DEMO_MGMT_FQDN chmod 700 update-grafana-dashboard.sh
ssh $DEMO_MGMT_FQDN "./update-grafana-dashboard.sh $MON_NODE $MONITORING_PASSWORD"

# Load grafana data 
cd grafana-dashboards
wizzy init
wizzy set grafana url http://$DEMO_AGENT_FQDN:3000/
wizzy set grafana username admin
wizzy set grafana password $MONITORING_PASSWORD


# Export == export from wizzy to grafana
wizzy export datasources
wizzy export dashboards

cd ../
