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

