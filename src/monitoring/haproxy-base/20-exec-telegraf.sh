#!/bin/bash

# Run telegraf as telegraf user
#exec /sbin/setuser telegraf /usr/bin/telegraf >>/var/log/telegraf.log 2>&1
/usr/bin/telegraf >> /var/log/telegraf.log 2>&1