#!/bin/bash

# Deploy the haproxy configuration
kubectl create configmap haproxy-config --from-file=haproxy/haproxy.cfg
kubectl get configmap haproxy-config -o yaml > haproxy-config.yaml

# Deploy the daemonset and expose the service
kubectl apply -f telegraf-haproxy-config.yaml -f haproxy-replicaset.yaml -f haproxy-service.yaml 
