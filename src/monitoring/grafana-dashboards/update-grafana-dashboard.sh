#!/bin/bash

MON_NODE=$1
MONITORING_PASSWORD=$2

if [ -z ${MON_NODE} ]; then
	echo "MON_NODE variable is not set"
	echo
	echo "Usage: "
	echo "update-grafana-dashboard.sh [MONITORING NODE] [MONITORING PASSWORD]"
	exit -1
fi

if [ -z ${MONITORING_PASSWORD} ]; then
	echo "MONITORING_PASSWORD variable is not set"
	echo
	echo "Usage: "
	echo "update-grafana-dashboard.sh [MONITORING NODE] [MONITORING PASSWORD]"
	exit -1
fi

HTTP_CONTENT="{ \"oldPassword\": \"admin\", \"newPassword\": \"$MONITORING_PASSWORD\", \"confirmNew\": \"$MONITORING_PASSWORD\" }"
echo $HTTP_CONTENT | curl -X PUT -H "Content-Type: application/json" -d @- http://admin:admin@$MON_NODE:3000/api/user/password
