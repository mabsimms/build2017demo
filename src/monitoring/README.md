# Monitoring 

This section covers how the monitoring solution was designed and implemented, along with
how to deploy the monitoring services and agents to the Swarm cluster.

This section's documentation needs much love.

## Monitoring design

The monitoring solution used for this demo was intended to demontrate Azure as an open platform
and leverage some common OSS packages for a great end to end monitoring experience capturing
metrics across the application and infrastructure.  The approach consists of these key 
components:

- InfluxDB.  Time series data store, great for ingesting, indexing and serving up metrics.
- Grafana.  Visualization and dashboarding tool for metrics.  Pulls data from influx and 
visualizes interactive dashboarmasimms@maslinbook:~/code/build2017demo/src/monitoring$ 



- Telegraf.  Metrics agent for pulling, aggregating and forwarding metrics streams to influx. 
Telegraf will be deployed on each Swarm node to capture container and host level metrics, as well as inside the haproxy container to capture real-time stats.

## Monitoring haproxy

TODO 

## Deployment

Deploying the monitoring services is relatively straightforward, consisting of opening the 
relevant ports in the load balancer (for remote access to grafana), and deploying the 
service and agent containers.

### Step 1 - opening load balancer ports

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
  "port": 2003,
**SNIP**
```

### Step 2 - Deploying the monitoring stack

## Holding area

### Profiling a .NET Core application

- https://github.com/dotnet/coreclr/blob/master/Documentation/project-docs/linux-performance-tracing.md

### Temp - working with local dev

```
sudo apt install docker.io
sudo apt-get install haproxy
wget https://dl.influxdata.com/telegraf/releases/telegraf_1.2.1_amd64.deb
sudo dpkg -i telegraf_1.2.1_amd64.deb

echo '
[[inputs.logparser]]
  ## file(s) to tail:
  files = ["/tmp/test.log"]
  from_beginning = false
  name_override = "test_metric"
  ## For parsing logstash-style "grok" patterns:
  [inputs.logparser.grok]
    patterns = ["%{COMBINED_LOG_FORMAT}"]

[[outputs.file]]
  ## Files to write to, "stdout" is a specially handled file.
  files = ["stdout"]' >> /tmp/telegraf.conf
```

Make 49-haproxy.conf look like:

```
# Enable listening on UDP port for haproxy entries
$ModLoad imudp
$UDPServerAddress 127.0.0.1
$UDPServerRun 512

# Create an additional socket in haproxy's chroot in order to allow logging via
# /dev/log to chroot'ed HAProxy processes
$AddUnixListenSocket /var/lib/haproxy/dev/log

# Send HAProxy messages to a dedicated logfile
if $programname startswith 'haproxy' then /var/log/haproxy.log
&~
```

# TODO

## Installing LogStash

To install (but not configure logstash):

```
echo 'deb http://packages.elastic.co/logstash/2.2/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash-2.2.x.list
apt-get update
apt-get install logstash
```

## Native haproxy install

```
sudo apt-get update
sudo apt install make
sudo apt install gcc
sudo apt install libpcre3 libpcre3-dev
sudo apt install libssl-dev
make
sudo make install

# TODO - this isn't quite right yet
```

## installing influx db

```
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.0.0_amd64.deb
sudo dpkg -i influxdb_1.0.0_amd64.deb
sudo service influxdb start
```

## Installing grafana

```
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.2.0_amd64.deb
sudo apt-get install -y adduser libfontconfig
sudo dpkg -i grafana_4.2.0_amd64.deb

systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server
sudo systemctl enable grafana-server.service
```

## Useful links

### Grok 
- https://github.com/hpcugent/logstash-patterns/blob/master/files/grok-patterns
- https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/haproxy
- https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html
- https://github.com/influxdata/telegraf/tree/master/plugins/inputs/logparser
- https://golang.org/pkg/time/#Parse
- https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html
- https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html


### Grafana

- http://docs.grafana.org/installation/troubleshooting/
- http://docs.grafana.org/installation/debian/

### Haproxy

- http://cbonte.github.io/haproxy-dconv/1.7/configuration.html#8.2
- https://www.haproxy.com/doc/aloha/7.0/haproxy/log_format_rules.html
- http://kvz.io/blog/2010/08/11/haproxy-logging/
- https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps

### RSyslog

- http://www.rsyslog.com/doc/v8-stable/_downloads/rsyslog-example.conf
- http://www.rsyslog.com/doc/rsyslog_conf_examples.html

### Telegraf

- https://github.com/influxdata/telegraf/tree/master/plugins/inputs/logparser
- https://www.influxdata.com/telegraf-correlate-log-metrics-data-performance-bottlenecks/

### Monitoring docker containers

- https://blog.vpetkov.net/2016/08/04/monitor-docker-resource-metrics-with-grafana-influxdb-and-telegraf/
