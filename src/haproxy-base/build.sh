#!/bin/bash

sudo docker build -t mabsimms/haproxy-base:latest .
sudo docker push mabsimms/haproxy-base:latest
