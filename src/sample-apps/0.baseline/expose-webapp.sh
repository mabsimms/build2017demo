#!/bin/bash

# kubectl expose deployment/webapp-0 
kubectl expose deployment/webapp-0 --port=80 --target-port=80 \
    --name=webapp --type=LoadBalancer
