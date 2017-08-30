# Deploying a Docker Swarm cluster in Azure Container Service

This demo leverages a Kubernetes cluster via the Azure Container 
Service for deploying and running containers.  This walks through the
steps and customizations for creating and configuring the cluster.

## Resource group creation and cluster deployment

The first step is to create the resource group (which will contain all of the demo resources),
the container registry and Kubernetes cluster. Before the deployment script
(`deploy-swarm-cluster.sh`) can be run the Azure CLI tools need to be installed, and valid
login token obtained.

This script is based on the Azure documentation for [Deploy a Kubernetes cluster in Azure Container Service](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-tutorial-kubernetes-deploy-cluster).

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
 
Once the prerequisites have been installed you can run the deploy-k8-cluster.sh 
script to deploy the cluster.  The cluster settings are defined in the 
`deployment-settings.sh` script.  Change these values to match your preferences.

```bash
export DEMO_RESOURCE_GROUP=masdemo-k8-rg
export DEMO_LOCATION=eastus2
export DEMO_CLUSTER_NAME=demok8
```

The deployment script proper validates the parameters, then creates the Azure
resources (resource group, container registry and kubernetes cluster).  The 
deployment steps are fairly straightforward (this demo uses standard ACS parameters):

```bash
# Create the resource group
az group create --name ${DEMO_RESOURCE_GROUP} \
    --location ${DEMO_LOCATION}

# Create the private container registry
az acr create --name ${DEMO_CLUSTER_NAME}registry \
    --resource-group ${DEMO_RESOURCE_GROUP} \
    --sku Basic \
    --admin-enabled true
az acr login --name ${DEMO_CLUSTER_NAME}registry

# Create the Kubernetes cluster
az acs create --orchestrator-type kubernetes \
    --resource-group ${DEMO_RESOURCE_GROUP} \
    --name ${DEMO_CLUSTER_NAME} \
    --generate-ssh-keys
```

Finally, the script installs the `kubectl` scripts then validates credentials 
and connectivity.

```bash
# Set up kubernetes command line and credentials
 sudo az acs kubernetes install-cli
 az acs kubernetes get-credentials \
     --resource-group=${DEMO_RESOURCE_GROUP} \
     --name=${DEMO_CLUSTER_NAME}
kubectl get nodes
```
 
This will finish by printing the set of nodes (3 agent nodes by default) to
the console.  Note that this is not a recommended production configuration
(single master node).

```
$ kubectl get nodes
NAME                    STATUS                     AGE       VERSION
k8s-agent-eac4717e-0    Ready                      12m       v1.6.6
k8s-agent-eac4717e-1    Ready                      12m       v1.6.6
k8s-agent-eac4717e-2    Ready                      12m       v1.6.6
k8s-master-eac4717e-0   Ready,SchedulingDisabled   12m       v1.6.6
```   
