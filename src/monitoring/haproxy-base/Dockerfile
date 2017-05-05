# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.21

# For more information on configuraing phusion base images
# https://github.com/phusion/baseimage-docker#getting_started

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

#####################################################################################################
# Install rsyslog (from https://blog.logentries.com/2014/03/how-to-run-rsyslog-in-a-docker-container-for-logging/)
#####################################################################################################
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise main universe" >> /etc/apt/source.list && \
    apt-get update && \
    apt-get -y install rsyslog
                                        
#####################################################################################################
# Install haproxy (from https://github.com/docker-library/haproxy/blob/1848d2933afbefd0e0a068dc7b5a753ab7842e6c/1.7/Dockerfile)
#####################################################################################################
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		liblua5.3-0 \
		libpcre3 \
		libssl1.0.0 \
	&& rm -rf /var/lib/apt/lists/*

ENV HAPROXY_MAJOR 1.7
ENV HAPROXY_VERSION 1.7.5
ENV HAPROXY_MD5 ed84c80cb97852d2aa3161ed16c48a1c

# see http://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -x \
	\
	&& buildDeps=' \
		gcc \
		libc6-dev \
		liblua5.3-dev \
		libpcre3-dev \
		libssl-dev \
		make \
		wget \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O haproxy.tar.gz "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" \
	&& echo "$HAPROXY_MD5 *haproxy.tar.gz" | md5sum -c \
	&& mkdir -p /usr/src/haproxy \
	&& tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
	&& rm haproxy.tar.gz \
	\
	&& makeOpts=' \
		TARGET=linux2628 \
		USE_LUA=1 LUA_INC=/usr/include/lua5.3 \
		USE_OPENSSL=1 \
		USE_PCRE=1 PCREDIR= \
		USE_ZLIB=1 \
	' \
	&& make -C /usr/src/haproxy -j "$(nproc)" all $makeOpts \
	&& make -C /usr/src/haproxy install-bin $makeOpts \
	\
	&& mkdir -p /usr/local/etc/haproxy \
	&& cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
	&& rm -rf /usr/src/haproxy \
	\
	&& apt-get purge -y --auto-remove $buildDeps

RUN useradd --system haproxy && \
    mkdir /run/haproxy && \
    chown haproxy:haproxy /run/haproxy && \
    mkdir /var/lib/haproxy && \
    mkdir -p /var/lib/haproxy/dev && \
    chown -R haproxy:haproxy /var/lib/haproxy

#####################################################################################################
# Install telegraf
#####################################################################################################
#RUN gpg \
    #--keyserver hkp://ha.pool.sks-keyservers.net \
    #--recv-keys 05CE15085FC09D18E99EFB22684A14CF2582E0C5

ENV TELEGRAF_VERSION 1.1.2

RUN apt-get update && apt-get install wget && \
    wget -q https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_amd64.deb.asc && \
    wget -q https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_amd64.deb && \    
    dpkg -i telegraf_${TELEGRAF_VERSION}_amd64.deb && \
    rm -f telegraf_${TELEGRAF_VERSION}_amd64.deb*

#####################################################################################################
# Install the baseline configuration and startup scripts
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

# TODO - service startups

#####################################################################################################
# Clean up APT when done.
#####################################################################################################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#####################################################################################################
# Expose HTTP/HTTPS ports
#####################################################################################################
EXPOSE 80
EXPOSE 443
