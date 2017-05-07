#!/bin/bash

# If this command does not run, install the prerequisites by:
# sudo apt-get install npm
# sudo npm install -g wizzy

wizzy init
wizzy set grafana url http://${AGENT_HOST}:3000
wizzy set grafana username ${GRAFANA_USER}
wizzy set grafana password ${GRAFANA_USER}
wizzy export dashboards
wizzy export datasources
