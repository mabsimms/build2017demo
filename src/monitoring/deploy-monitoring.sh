#!/bin/bash

# Ensure that we have the disk provider registered
kubectl create -f default-azure-storage.yaml

# Label nodes such that the first agent node
# is dedicated for monitoring, and all other
# agent nodes are labelled for "work"
MON_NODE=`kubectl get nodes | grep "\-0" | grep agent | cut -d' ' -f1`
WRK_NODES=``
kubectl label nodes $MON_NODE role=monitoring


# Deploy the influx db container with attached storage and config
kubectl create -f influxdb-config.yaml
kubectl create -f influxdb-storage.yaml
kubectl create -f influxdb-service.yaml
kubectl expose rs influxdb

# Deploy grafana
kubectl create -f grafana-storage.yaml
kubectl create -f grafana-service.yaml
kubectl expose rs grafana

# Deploy the monitoring agents (telegraf) as a global service
# onto all nodes
kubectl create -f telegraf-agent-config.yaml
kubectl create -f telegraf-agent-service.yaml

# Test - connect grafana ports
INFLUX_POD=$(kubectl get pods -l app=influxdb -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $INFLUX_POD 48857:8086

# Test - connect grafana ports
GRAFANA_POD=$(kubectl get pods -l app=grafana -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $GRAFANA_POD 48858:3000