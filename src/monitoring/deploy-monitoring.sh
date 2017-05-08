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
ssh $DEMO_MGMT_FQDN export MONITORING_PASSWORD=$MONITORING_PASSWORD
ssh $DEMO_MGMT_FQDN export MON_NODE=$MON_NODE
scp update-grafana-dashboard.sh $MGMT_FQDN:update-grafana-dashboard.sh
ssh $DEMO_MGMT_FQDN chmod 700 update-grafana-dashboard.sh
ssh $DEMO_MGMT_FQDN ./update-grafana-dashboard.sh

curl -X PUT -H "Content-Type: application/json" -d '{
  "oldPassword": "admin",
  "newPassword": "newpass",
  "confirmNew": "newpass"
}' http://admin:admin@<your_grafana_host>:3000/api/user/password


ssh $DEMO_MGMT_FQDN "sudo apt-get update && sudo apt-get install -y npm && sudo npm install -g wizzy"
ssh $DEMO_MGMT_FQDN "sudo ln -s /usr/bin/nodejs /usr/bin/node"
ssh $DEMO_MGMT_FQDN "sudo wizzy init"
ssh $DEMO_MGMT_FQDN "sudo wizzy set grafana url http://${MON_NODE}:3000"

ssh $DEMO_MGMT_FQDN "sudo wizzy set grafana envs demo url http://{$DEMO_AGENT_FQDN}:3000"
ssh $DEMO_MGMT_FQDN "sudo wizzy set grafana username $MONITORING_USERNAME"
ssh $DEMO_MGMT_FQDN "sudo wizzy set grafana password $MONITORING_PASSWORD"

# Update the grafana password

# wizzy set grafana envs demo username $MONITORING_USERNAME
# wizzy set grafana envs demo password $MONTIORING_PASSWORD
# wizzy set context demo

# # Export == export from wizzy to grafana
# wizzy export datasources
# wizzy export dashboards
