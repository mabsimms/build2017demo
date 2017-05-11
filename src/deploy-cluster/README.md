# Deploying a Docker Swarm cluster in Azure Container Service

This demo leverages a Docker Swarm cluster via the Azure Container 
Service for deploying and running containers.  This walks through the
steps and customizations for creating and configuring the cluster.

## Step 1 - Resource group creation and cluster deployment

The first step is to create the resource group (which will contain all of the demo resources) 
and the Swarm Cluster by deploying an ACS ARM template.  Before the deployment script
(deploy-swarm-cluster.sh) can be run the Azure CLI tools need to be installed, and valid
login token obtained.

This script is based on the Azure documentation (https://docs.microsoft.com/en-us/azure/container-service/container-service-deployment)[Container Service Deployment].

```bash
# Ensure that Python and PIP are installed
sudo apt-get update
sudo apt-get install python
sudo apt-get install python-pip

# Install helper utilities
sudo apt-get install jq

# Install the Azure CLI on Linux via python/pip
pip install --user azure-cli

# Get an authorization token for your Azure subscription
az login
```

Once the prerequisites have been installed, generate an SSH public/private key
pair to use for authentication into the cluster.  The default file path used
by the setup scripts is ~/.ssh/swarm_rsa, but that can be overridden by 
changing the SSH_[PUBLIC|PRIVATE]_KEY_FILE values in the setup script.

```bash
masimms@maslinbook:~/code/build2017demo/src/deploy-cluster$ ssh-keygen -f ~/.ssh/swarm_rsa
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/masimms/.ssh/swarm_rsa.
Your public key has been saved in /home/masimms/.ssh/swarm_rsa.pub.
The key fingerprint is:
SHA256:OveRI+WvTaXv2Xjj/ziKoNYYP7z+5N5LN5pQSFc39/M masimms@maslinbook
```

Once the prerequisites have been installed and the ssh key pair generated,
you can run the deploy-swarm-cluster.sh script to deploy the cluster.  The
first phase of the script sets up the relevant configuration 
variables.  

```bash
# Change these to fit your environment
DNS_PREFIX=masbld
AGENT_COUNT=8

# Changing these are optional
USERNAME=masimms
RESOURCE_GROUP=${DNS_PREFIX}-rg
LOCATION=eastus2
DEPLOYMENT_NAME=demo

# Leave blank to auto-generate an SSH public key
SSH_PUBLIC_KEY_FILE=${HOME}/swarm_rsa.pub
SSH_PRIVATE_KEY_FILE=${HOME}/swarm_rsa
KEYVAULT_RG=sharedkv-rg
KEYVAULT_NAME=sharedkv

# Deploy DC/OS 
TEMPLATE_URI="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/azuredeploy.json"
```

The next phase of the script sets up the SSH authentication keys, creating them if 
necessary and ensuring that they are stored in Keyvault (not directly used in this demo,
but very handy for not having the only private key stored on a single machine).

```bash

# Create an SSH key for connecting to the cluster
if [ -f ${SSH_PUBLIC_KEY_FILE} ]; then
    echo "Using SSH public key from ${SSH_PUBLIC_KEY_FILE}"
    SSH_PUBLIC_KEY=`cat ${SSH_PUBLIC_KEY_FILE}`
else
    echo "No ssh public key file specified; generating new file"
    ssh-keygen -f ${SSH_PRIVATE_KEY_FILE}
    SSH_PUBLIC_KEY=`cat ${SSH_PUBLIC_KEY_FILE}`
fi

# Store the SSH public/private key pair in Azure Keyvault
echo -n "Checking for keyvault ${KEYVAULT_NAME}"
KV_EXISTS=`az keyvault show ${KEYVAULT_NAME} 2>&1 | grep error | wc -l`
if [ $KV_EXISTS -gt 0 ]; then
    echo " does not exist"
    echo "Keyvault ${KEYVAULT_NAME} does not exist; creating"
    az group create --name ${KEYVAULT_RG} --location ${LOCATION}
    az keyvault create --name ${KEYVAULT_NAME} --resource-group ${KEYVAULT_RG} \
        --location "${LOCATION}" --sku standard --enabled-for-template-deployment true \
        --enabled-for-deployment true --output table
else
        echo " exists"
fi

# Upload to key vault
echo "Uploading SSH keys to keyvault"
az keyvault secret set --vault-name ${KEYVAULT_NAME} --encoding base64 \
    --name ${DNS_PREFIX}-key-private --file "${SSH_PRIVATE_KEY_FILE}" 
az keyvault secret set --vault-name ${KEYVAULT_NAME} --encoding base64 \
    --name ${DNS_PREFIX}-key-public --file "${SSH_PUBLIC_KEY_FILE}" 
```

The third phase of the script maps the configuration variables into a copy of the 
ARM template parameter file.  Note the use of *|* as a sed delimiter, as the */* 
character is common in the text output of an SSH public key.

```bash

# Update the ARM template parameters based on the settings above
PARAMETERS_FILE=deploy-${DNS_PREFIX}.json
echo "Creating deployment parameters file ${PARAMETERS_FILE}"
cp azuredeploy.parameters.template.json ${PARAMETERS}.json
sed -i'' -e "s/##DNS_PREFIX##/${DNS_PREFIX}/" $PARAMETERS_FILE
sed -i'' -e "s/##USERNAME##/${USERNAME}/" $PARAMETERS_FILE
sed -i'' -e "s/##AGENT_COUNT##/${AGENT_COUNT}/" $PARAMETERS_FILE
sed -i'' -e "s|##SSH_PUBLIC_KEY##|${SSH_PUBLIC_KEY}|" $PARAMETERS_FILE
``` 

The fourth phase of the script actually creates the resource group and deploys the 
Swarm cluster via the Azure Container Service.  Deploying the Swarm cluster can 
take up to 10 minutes.

```bash
# Deploy the cluster
echo "Deploying resource group ${RESOURCE_GROUP} to region ${LOCATION}"
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"

echo "Deploying ACS cluster into resource group ${RESOURCE_GROUP}"
az group deployment create -g ${RESOURCE_GROUP} -n ${DEPLOYMENT_NAME} \
    --template-uri ${TEMPLATE_URI} \
     --parameters @${PARAMETERS_FILE}
```

The fifth and final phase of the cluster deployment script saves all of the 
environment variables into a (.git ignored) file that will be used to drive the 
rest of the automation around cluster connectivity and configuration.

```bash
# Create the environment-masbld.sh file
echo "export DEMO_RESOURCE_GROUP=${RESOURCE_GROUP}" >> environment-masbld.sh
echo "export DEMO_LOCATION=${LOCATION}" >> environment-masbld.sh
echo "export DEMO_DEPLOYMENT_NAME=${DEPLOYMENT_NAME}" >> environment-masbld.sh
echo "export DEMO_DNS_PREFIX=${DNS_PREFIX}" >> environment-masbld.sh
echo "export DEMO_SSH_PUBLIC_KEY_FILE=${SSH_PUBLIC_KEY_FILE}" >> environment-masbld.sh
echo "export DEMO_SSH_PRIVATE_KEY_FILE=${SSH_PRIVATE_KEY_FILE}" >> environment-masbld.sh
echo "export DEMO_KEYVAULT_NAME=${KEYVAULT_NAME}" >> environment-masbld.sh
```

Once the cluster has been deployed, you will be able to check its status via

```bash
masimms@maslinbook:~/code/build2017demo/src/deploy-cluster$ az acs list --output table
Location    Name                        ProvisioningState    ResourceGroup
----------  --------------------------  -------------------  ---------------
eastus2     containerservice-masbld-rg  Succeeded            MASBLD-RG
```

## Step 2 - Cluster Connectivity

After the cluster has been created we need to establish an SSH tunnel to the cluster, and configure our
local environment variables such that docker commands (including docker-compose) will use the tunnel to the 
remote Swarm cluster instead of any local docker installation.

This section and script are based on [https://docs.microsoft.com/en-us/azure/container-service/container-service-connect](Remote Connectivity) in the Azure documentation.

The script (connect-swarm-cluster.sh) starts by looking up the ACS component
values (IP endpoints).

```bash
# Ports for Swarm management
LOCAL_PORT=2375
REMOTE_PORT=2375

# Other settings - ensure that you have source'ed the
# environment-dnsprefix.sh file
USERNAME=${DEMO_USERNAME}
REGION=${DEMO_LOCATION}
PATH_TO_PRIVATE_KEY=${DEMO_SSH_PUBLIC_KEY_FILE}

echo "Looking up ACS deployment name"
ACS_NAME=`az acs list --resource-group ${DEMO_RESOURCE_GROUP} | jq .[].name | sed 's/\"//g'`

echo "Looking up management FQDN"
MGMT_FQDN=`az acs show --name ${ACS_NAME} --resource-group ${DEMO_RESOURCE_GROUP} | \
    jq .masterProfile.fqdn | sed 's/\"//g'`
```

It then creates the ssh tunnel that will be used to proxy docker commands 
to the swarm cluster.

```bash
echo "Connecting tunnel to management endpoint $FQDN"
ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${MGMT_FQDN} \
    -i ${PATH_TO_PRIVATE_KEY}
export DOCKER_HOST=:2375
```

Finishing up by adding the context environment variables to the 
environment file, including an alias (connect-swarm) to recreate the
ssh connection.

```bash

# Get the FQDN of the agent public iP
echo "Looking up agent public ip name"
AGENT_PIP_NAME=`az network public-ip list --resource-group ${DEMO_RESOURCE_GROUP} \
    --output table | grep agents | tr -s ' ' | cut -d' ' -f5`
echo "Looking up agent public ip fqdn"
AGENT_FQDN=`az network public-ip show --name ${AGENT_PIP_NAME} \
    --resource-group ${DEMO_RESOURCE_GROUP} | jq .dnsSettings.fqdn | sed 's/\"//g'`

# Add these settings to the environment file
echo "Adding connection values to environment settings"
echo "export DEMO_ACS_NAME=${ACS_NAME}" >> ${DEMO_ENV_PATH} 
echo "export DEMO_MGMT_FQDN=${MGMT_FQDN}" >> ${DEMO_ENV_PATH} 
echo "export DEMO_AGENT_FQDN=${AGENT_FQDN}" >> ${DEMO_ENV_PATH} 
echo "export DOCKER_HOST=:2375" >>  ${DEMO_ENV_PATH} 
echo "alias connect-swarm='ssh -fNL ${LOCAL_PORT}:localhost:${REMOTE_PORT} -p 2200 ${USERNAME}@${MGMT_FQDN} -i ${PATH_TO_PRIVATE_KEY}'" >> ${DEMO_ENV_PATH}

source ${DEMO_ENV_PATH} 
```

When this script has completed, the ssh tunnel should be created, the
DOCKER_HOST variable set to use the loopback ssh tunnel, and docker commands
will route to the remote swarm host.  Test this by executing the docker info
command.

```bash
masimms@lindev:~$ docker info
... SNIP ...
Nodes: 8
 swarm-agent-826B303A000000: 10.0.0.4:2375
  └ Status: Healthy
  └ Containers: 0
  └ Reserved CPUs: 0 / 4
WARNING: No kernel memory limit support
  └ Reserved Memory: 0 B / 14.38 GiB
  └ Labels: executiondriver=<not supported>, kernelversion=3.19.0-65-generic, operatingsystem=Ubuntu 14.04.4 LTS, storagedriver=aufs
  └ Error: (none)
  └ UpdatedAt: 2017-05-07T23:11:40Z
 swarm-agent-826B303A000001: 10.0.0.5:2375
  └ Status: Healthy
  └ Containers: 0
... SNIP ...
```

## Step 3 - Networking and cluster configuration

The final step in cluster preparationw will be to run the appropriate script (init-cluster.sh) to configure
the Docker network(s), configure the underlying VMs, and open up the load balancer probes and routes to 
access the monitoring tools (ELK, Grafana, InfluxDB) used later in the demo.

The first step of the script creates a docker *swarm* network for swarm service containers
to communicate with each other.  Note - ordinary docker containers (i.e. docker run) cannot
attach to this network.

```bash
# Note: all of the docker-compose files assume the presence of the build2017-demo-network
# global network.  If you change this value you will have to update all of the compose 
# files.
NETWORK_NAME=build2017-demo-network
NETWORK_RANGE=10.0.5.0/24

# Create a shared (global) network for the demo resources
# https://docs.docker.com/engine/userguide/networking/get-started-overlay/#run-an-application-on-your-network
docker network create --driver overlay --subnet ${NETWORK_RANGE} ${NETWORK_NAME} --attachable

# TODO - ssh to all of the machines and update sysctl for elasticsearch
```

The second step in the script updates kernel parameters across the cluster, including 
the sysctl changes needed for ElasticSearch to run.  TODO - still under development.

## Further reading and resources


