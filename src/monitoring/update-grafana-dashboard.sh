#!/bin/bash

curl -X PUT -H "Content-Type: application/json" -d '{
  "oldPassword": "admin",
  "newPassword": "$MONITORING_PASSWORD",
  "confirmNew": "$MONITORING_PASSWORD"
}' http://admin:admin@$MON_NODE:3000/api/user/password
