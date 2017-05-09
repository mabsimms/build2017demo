#!/bin/sh

# Build the update container
echo "Building container to execute ef database update in Swarm network.."
docker build -t mabsimms/masbld_1_efupdate . -f Dockerfile-efinit
docker push mabsimms/masbld_1_efupdate

# Note - container must be deployed as a Swarm service to join the 
# swarm overlay network (i.e. cannot docker run this directly)
echo "Deploying container as swarm service "
docker stack deploy --compose-file docker-compose-database.yml dbinit
