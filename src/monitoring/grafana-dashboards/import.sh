#!/bin/bash

# If this command does not run, install the prerequisites by:
# sudo apt-get install npm
# sudo npm install -g wizzy

wizzy init
wizzy set grafana url http://localhost:3000
wizzy set grafana username admin
wizzy set grafana password admin
wizzy export dashboards
wizzy export datasources
