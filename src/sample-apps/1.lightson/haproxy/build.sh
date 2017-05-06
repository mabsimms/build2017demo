#!/bin/bash

sudo docker pull mabsimms/haproxy-base:latest
sudo docker build -t mabsimms/bld2017_haproxy_1:latest .
sudo docker push mabsimms/bld2017_haproxy_1:latest

