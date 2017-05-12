# Monitoring 

This aspect of the demo covers how to implement Docker container monitoring in a
Docker Swarm cluster by using InfluxDB, Grafana and Telegraf.  It also covers
how to extend a typical Haproxy container deployment to have integrated metrics
reporting via telegraf's logstash/grok input parser capability.
 
## Monitoring design

The monitoring solution used for this demo was intended to demontrate Azure as an open platform and leverage some common OSS packages for a great end to end monitoring experience capturing metrics across the application and infrastructure.  The approach consists of these key components:

- [InfluxDB](influxdb).  Time series data store, great for ingesting, indexing and serving up metrics.

- [Grafana](grafana).  Visualization and dashboarding tool for metrics.  Pulls data from influx and visualizes interactive dashboards.
 
- [Telegraf](telegraf).  Metrics agent for pulling, aggregating and forwarding metrics streams to influx.

Telegraf will be deployed on each Swarm node to capture container and host level metrics, as well as inside the haproxy container to capture real-time stats.

TODO - picture here

## Real-time Monitoring of Haproxy with Telegraf

One of the approaches taken in this demo is leveraging telegraf to pull real-time metrics out of haproxy and send them to influx.  This pipeline works by:

```
[Haproxy] -> UDP -> [RsyslogD] -> haproxy.log -> [Telegraf file grok] -> [Influx]
```

Haproxy emits syslog log records to the local UDP interface (to avoid any blocking
or contention).  In this configuration, `rsyslogd` is configured to pick up these
records and write them into `/var/log/haproxy.log`.  From there telegraf will 
parse the log file lines into structured records, aggregate them in a sliding window
and send those metrics to influx.

The first step is the haproxy configuration for emitting logs.

```   
log /dev/log    local2
log /dev/log    local1 notice
...
log-format "%ci [%t] %s %HM %HP %HV %ST %U %B %H %Tq/%Tw/%Tc/%Tr/%Tt \"%[capture.req.hdr(0)]\" %bi:%bp %fi:%fp %ac/%fc/%bc/%sc/%rc"
```

This log format tells haproxy to emit syslog records with the following information:

| Haproxy Code  | Variable       | Description  |
| ------------- | -------------- | ------------ |
| %ci           | CI             | TODO         |
| %HM           | t              | TODO         |
| %HP           | t              | TODO         |
| %HV           | t              | TODO         |
| %ST           | t              | TODO         |
| %U            | t              | TODO         |
| %B            | t              | TODO         |
| %H            | t              | TODO         |
| %Tq           | t              | TODO         |
| %Tw           | t              | TODO         |
| %Tc           | t              | TODO         |
| %Tr           | t              | TODO         |
| %Tt           | t              | TODO         |
| %hdr(0)       | t              | TODO         |
| %bi           | t              | TODO         |
| %bp           | t              | TODO         |
| %fi           | t              | TODO         |
| %ac           | t              | TODO         |
| %fc           | t              | TODO         |
| %bc           | t              | TODO         |
| %sc           | t              | TODO         |
| %rc           | t              | TODO         |

Note that the `User-Agent` header is `hdr(0)` because the front ends are configured to capture that as the first header via

```
capture request header User-Agent len 64
capture request header Referer len 200
```

The next step is to configure rsyslogd to capture this information and write it
into `/var/log/haproxy.log` as seen in `49-haproxy.conf`:

```
# Enable listening on UDP port for haproxy entries
$ModLoad imudp
$UDPServerAddress 127.0.0.1
$UDPServerRun 512

# Create an additional socket in haproxy's chroot in order to allow logging via
# /dev/log to chroot'ed HAProxy processes
$AddUnixListenSocket /var/lib/haproxy/dev/log

# Set up template (no syslog header information)
$template BareFormat,"%msg%\n"

# Send HAProxy messages to a dedicated logfile
if $programname startswith 'haproxy' then /var/log/haproxy.log;BareFormat
```

Next, we configure telegraf to pick up this file, and use its internal grok 
engine (very similar to the logstash grok plugin):

```
[[inputs.logparser]]
  ## file(s) to tail:
  files = ["/var/log/haproxy.log"]
  from_beginning = false
  name_override = "requests"
  ## For parsing logstash-style "grok" patterns:
  [inputs.logparser.grok]
    patterns = ["%{CUST_LOG}"]
    custom_patterns = '''
      CUST_LOG %{IP:client_ip} %{HAPROXYDATE:date} %{WORD:server:tag} %{WORD:method} %{URIPATH:uri:tag} HTTP/%{NUMBER:httpver:float} %{NUMBER:statuscode:tag} %{NUMBER:csBytes:int} %{NUMBER:scBytes:int} %{WORD:hostname} %{NUMBER:client_wait:int}/%{NUMBER:queue_wait:int}/%{NUMBER:connection_wait:int}/%{NUMBER:server_wait:int}/%{NUMBER:elapsed:int} %{QS:useragent} %{IP:fe_ip}:%{NUMBER:fe_port} %{IP:be_ip}:%{NUMBER:be_port} %{NUMBER:conn_active:int}/%{NUMBER:conn_fe:int}/%{NUMBER:conn_be:int}/%{NUMBER:conn_srv:int}/%{NUMBER:retries:int}
      HAPROXYDATE \[%{MONTHDAY:haproxy_hour}/%{MONTH:haproxy_month}/%{YEAR:haproxy_year}:%{HOUR:haproxy_hour}:%{MINUTE:haproxy_minute}:%{SECOND:haproxy_second}\]
    '''

[[outputs.influxdb]]
  urls = ["http://$INFLUX_SERVER:$INFLUX_PORT"] # required
  database = "$INFLUX_DB"
  timeout = "5s"
```

This is rather complicated (i.e. it took me a day or two to get this working properly), so let's break down line-by-line what's going on.

```
[[inputs.logparser]]
  ## file(s) to tail:
  files = ["/var/log/haproxy.log"]
  from_beginning = false
  name_override = "requests"
```

We start by registering a telegraf input plugin (TODO - links) for parsing logfiles, 
looking at the tail of `/var/log/haproxy.log`, with the influxdb series name 
to be called `requests` (i.e. when the data shows up in grafana, it will be called
`requests`).

The final step is to define the parser for going from log file records to 
structured event records with metrics to go to influx.  This configuration states
that there is a single pattern type to look for (at this point, this configuration
only looks for haproxy records).

```
patterns = ["%{CUST_LOG}"]
```

The `custom_patterns` section outlines the two parsing codes - one to define how
haproxy writes out datetime records `HAPROXYDATE` as well as the actual log parser
definition `CUST_LOG`.

Each record takes the form:

```
{REGEX_MATCH_TYPE:NAME:INFLUX_DB_TYPE}
```

Thus we have as some examples:


| Code    | Regex Matches  | Variable Name | Influx Type |  
| ------- | -------- | ------------- | ----------- |
| %{IP:client_ip} | IP address    |  client_ip   |  string (default) |
| %{WORD:method} | Single word    |  method   |  string (default) |
| %{URIPATH:uri:tag} | URI path    |  uri   | tag (string - indexed by influx) |
| %{NUMBER:statuscode:tag} | Number | statuscode | tag (string - indexed by influx |
| %{NUMBER:csBytes:int} | Number | csBytes | integer (use for math in influx) |

Writing a parsing element requires getting three aspects correct:

- Regex match.  The regex match codes (available here TODO) are used by the grok
parser engine to pick up and match lines.  They do not assert how telegraf treats the
data fragment, simply how it locates it.

- Name.  The name assigned by telegraf to the match.

- Type. How telegraf interprets and treats the match.  There are four primary types 
used in this demo, outlined below.

| Influx Type | Description |
| ----------- | ----------- | 
| string (default) | Standard interpretation type.  Can be selected in influx, but cannot be used in a group by statement.
| tag | String type, can be used in a group by statement.
| int | Integer numeric type, can be used in aggregations and other math operators.
| float | Float numeric type, can be used in aggregations and other math operators.
 
The initial mistakes I made when putting together the parser were (a) not understanding the difference between the regex match and (b) how influx handles grouping series by tag.  Regex'ing out a NUMBER can be parsed by influx as a string
(and thus not available for aggregation or other metrics operations in influx), and
the individual data series are grouped by tags - if you don't flag a variable as a 
tag, it cannot be used for grouping.

As our container consists of three processes (haproxy, rsyslogd and telegraf) combining to form a logical self-contained micro service need to use a base image
that can handle *safe* scheduling of multiple processes.  For this, we'll use the
phusion base image (TODO - link), with a fairly complicated [Dockerfile](TODO). 

After installing the base services, the startup tasks are registered via:

```
#####################################################################################################
COPY 49-haproxy.conf /etc/rsyslog.d/49-haproxy.conf
COPY telegraf-haproxy.conf /etc/telegraf/telegraf.conf
COPY haproxy.cfg /etc/haproxy.cfg

# Remove the built-in sys log utils
RUN rm -rf /etc/service/syslog-ng && \
    rm -rf /etc/service/syslog-forwarder

# Haproxy
RUN mkdir /etc/service/haproxy
COPY 30-exec-haproxy.sh /etc/service/haproxy/run
RUN chmod +x /etc/service/haproxy/run

# RSyslogD
RUN mkdir /etc/service/rsyslogd
COPY 10-exec-rsyslogd.sh /etc/service/rsyslogd/run
RUN chmod +x /etc/service/rsyslogd/run

# Telegraf
RUN mkdir /etc/service/telegraf
COPY 20-exec-telegraf.sh /etc/service/telegraf/run
RUN chmod +x /etc/service/telegraf/run

ENV INFLUX_SERVER localhost
ENV INFLUX_PORT 8086
ENV INFLUX_DB telegraf 
```

With the environment variables for finding the influx server defined (they will 
need to be overridden when we deploy the monitoring agent via Swarm).

## Deploying the monitoring stack

Deploying the monitoring services is relatively straightforward, consisting  deploying the service and agent containers, then opening the relevant ports in the load balancer (for remote access to grafana, and optionally debugging influx with direct connections).

The first step in deploying the monitoring stack is deploying influxdb and 
grafana to the Docker Swarm cluster, along with a telegraf agent per node (to 
capture host level and container stats).

All of this configuration and deployment is encapsulated in the `deploy-monitoring.sh` script.  The first step in the script simply checks to see
if a `MONITORING_PASSWORD` has been configured, as the flow will not open up public
access to the grafana endpoint until the default password has been changed.

```bash
#####################################################################################
# Ensure that the pre-requisites and environment variables for login 
# usernames/passwords are set
#####################################################################################
#if [ -z $MONITORING_USERNAME ]; then
#    echo "Need to set environment variable MONITORING_USERNAME before deploying monitoring tools"
#    exit
#fi
MONITORING_USERNAME=admin

if [ -z $MONITORING_PASSWORD ]; then
    echo "Need to set environment variable MONITORING_PASSWORD before deploying monitoring tools"
    exit
fi
```

The next step in the script flags one of the nodes in the Swarm cluster as a 
monitoring node, by using labels.  This will allow the use of placement constraints
(TODO) to cleanly separate monitoring and production work on the cluster.

```bash
# Set the monitoring label on the first node
MON_NODE=`docker node ls | grep agentpublic | sort -k2 | head -1 | tr -s ' ' | cut -d' ' -f2`

SAVEIFS=$IFS
IFS=$'\n'
WRK_NODES=(`docker node ls | grep agentpublic | sort -k2 | tail -n +2 | tr -s ' ' | cut -d' ' -f2 `)
IFS=$SAVEIFS

echo "Setting node $MON_NODE with label role=monitoring"
docker node update $MON_NODE --label-add role=monitoring

for i in "${WRK_NODES[@]}"
do
   echo "Setting node $i with label role=worker"
   docker node update $i --label-add role=worker
done
```

In this script the first node is labelled with `role=monitoring` and the other nodes
labelled with `node=worker`.  The next step is to ensure that the the 
underlying containers are built and pushed to a repository (in this case Docker 
Hub).  

```bash
# Build the monitoring containers
cd influxdb
./build.sh
cd ../

cd host
./build.sh
cd ../

# Deploy the monitoring solution
echo "Pulling containers.."
docker-compose pull
```
 
The script derives from the standard published influx container to COPY an updated
`influxdb.conf` file into the packaged container.  This avoids having to use volume
mapping to pass the configuration file to a live container.

The final step in deployment is to use `docker stack` to start the service set on the Swarm cluster.

```bash
echo "Starting containers.."
docker stack deploy --compose-file docker-compose.yml monitoring
``` 

The `docker-compose.yml` file contains the definition for the services, and how 
they will communicate:

```yml
version: '3'

services:
  # Baseline influx db
  influxdb:
    image: mabsimms/mas_influxdb:latest
    ports:
    #  - "8086:8086"
     volumes:
      - influx-data:/var/lib/influxdb
    environment:
      - INFLUXDB_GRAPHITE_ENABLED=1
    deploy:
      placement:
        constraints: [node.labels.role == monitoring]

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    deploy:
      placement:
        constraints: [node.labels.role == monitoring]

#  elk:
#    image: sebp/elk:latest
#    ports:
#      - "5601:5601"
#    volumes:
#      - /mnt/docker/elk:/var/lib/elasticsearch
#    environment:
#      - constraint:node==monitoring

  telegrafhost:
    image: 'mabsimms/telegraf-host:latest'
    deploy:
      mode: global
    environment:
      - INFLUX_SERVER=influxdb
      - INFLUX_PORT=8086
      - INFLUX_DB=host
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"

networks:
  default:
    external:
      name: build2017-demo-network

volumes:
  grafana-data:

  influx-data:
```

The interesting parts of the compose file for this configuration are:

- The placement constraints are applied by pinning the monitoring services to nodes where the label `role` is equal to `monitoring` via `constraints: [node.labels.role == monitoring]`.

- All services will use the default `build2017-demo-network` (which was pre-created) as a shared Swarm network.

- Named volumes are used for durable data storage in the cluster.

- The `/var/run/docker.sock` path is mapped into the telegraf host container to allow the agent to poll docker statistics.

## Configuring the monitoring stack

TODO - how to run the scripts to change the default passwords, import 
dashboards and data sources, etc.

### Opening load balancer ports

To open the relevant load balancer ports (3000 for grafana), execute the open-ports.sh 
script.

```bash
./open-ports.sh 
```

Which results in output similar to:

```bash
Using load balancer name swarmm-agentpublic-20121181
Using back end pool name swarmm-agentpublic-20121181
Using front end name swarmm-agentpublic-20121181
Creating load balancer probe for port 2003
{
  "etag": "W/\"b78df911-27a0-4c03-8448-93b2437f6202\"",
  "id": "/subscriptions/3e9c25fc-55b3-4837-9bba-02b6eb204331/resourceGroups/masbld-rg/providers/Microsoft.Network/loadBalancers/swarmm-agentpublic-20121181/probes/probe2003",
  "intervalInSeconds": 15,
  "loadBalancingRules": null,
  "name": "probe2003",
  "numberOfProbes": 2,
  "port": 3000,
**SNIP**
```

At this point the container metrics should be flowing into and visible in grafana.

TODO - sample screenshot.

## Profiling a .NET Core application

TODO - due to Docker Swarm not yet supporting running priviledged containers, 
this aspect of the demo is not working.

For details on profiling .NET Core applications on Azure, please refer to [https://github.com/dotnet/coreclr/blob/master/Documentation/project-docs/linux-performance-tracing.md](https://github.com/dotnet/coreclr/blob/master/Documentation/project-docs/linux-performance-tracing.md)
    
## Useful links

This demo would not have been even remotely probable without some truly awesome
blog posts, writeups and documentation on how to use the the various components
leveraged in this demo.

### Telegraf & Grok 

 - Awesome writeup on using the logparser plugin for telegraf;  [https://www.influxdata.com/telegraf-correlate-log-metrics-data-performance-bottlenecks/](https://www.influxdata.com/telegraf-correlate-log-metrics-data-performance-bottlenecks/).

- Great writeup on using the docker source plugin for telegraf for container monitoring; [https://blog.vpetkov.net/2016/08/04/monitor-docker-resource-metrics-with-grafana-influxdb-and-telegraf/](https://blog.vpetkov.net/2016/08/04/monitor-docker-resource-metrics-with-grafana-influxdb-and-telegraf/).

Grok, or more especially the implementation of grok leveraged by telegraf can be 
highly .. challenging :) to get up and running correctly.  These links are helpful when getting up to speed on writing grok filters.

- The list of the core regex patterns used for extracting variables and fragments, such as NUMBER;  [https://github.com/hpcugent/logstash-patterns/blob/master/files/grok-patterns](https://github.com/hpcugent/logstash-patterns/blob/master/files/grok-patterns).

- The haproxy match patterns for common haproxy output types; [https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/haproxy](https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/haproxy).

- The logstash syntax for writing filters; slightly different than the telegraf grok implementation, but close enough to get up and running;[https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html).

- The telegraf logparser plugin documentation; [https://github.com/influxdata/telegraf/tree/master/plugins/inputs/logparser](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/logparser).
   
### Haproxy

- Haproxy configuration manual; [  http://cbonte.github.io/haproxy-dconv/1.7/configuration.html#8.2](  http://cbonte.github.io/haproxy-dconv/1.7/configuration.html#8.2).

- Documentation on the log format rules and codes; [https://www.haproxy.com/doc/aloha/7.0/haproxy/log_format_rules.html](https://www.haproxy.com/doc/aloha/7.0/haproxy/log_format_rules.html).


- Great writeup on how to go from haproxy to rsyslog to files; [http://kvz.io/blog/2010/08/11/haproxy-logging/](http://kvz.io/blog/2010/08/11/haproxy-logging/).

- Nice tutorial on setting up front end and back end pools for haproxy with health probes;  [https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps](https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps).

### RSyslog

- Sample rsyslog configuration file; [http://www.rsyslog.com/doc/v8-stable/_downloads/rsyslog-example.conf](  http://www.rsyslog.com/doc/v8-stable/_downloads/rsyslog-example.conf)
 