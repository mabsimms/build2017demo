# Monitoring 

## Temp - working with local dev

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
