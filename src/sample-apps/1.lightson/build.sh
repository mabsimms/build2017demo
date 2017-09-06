#!/bin/bash

# Create the updated configuration map from the haproxy cfg file
kubectl create configmap haproxy-config --from-file=haproxy/haproxy.cfg
kubectl get configmap haproxy-config -o yaml > haproxy-config.yaml


