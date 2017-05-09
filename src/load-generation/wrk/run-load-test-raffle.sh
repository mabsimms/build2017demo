#!/bin/bash

#ENDPOINT="http://masbldagent.eastus2.cloudapp.azure.com/api/ping"
ENDPOINT="http://masbldagent.eastus2.cloudapp.azure.com/api/raffle"
echo "Testing endpoint ${ENDPOINT}"
curl -v ${ENDPOINT}
echo

wrk -c 1000 -d 30m -t 1000 --rate 5000 ${ENDPOINT}
