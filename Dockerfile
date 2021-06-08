FROM debian:stretch

ARG RTPENGINE_VERSION=mr9.4.1.1

RUN apt-get update \
  && apt-get -y --quiet --force-yes upgrade curl iproute2 \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    gcc \
    g++ \
    make \
    build-essential \
    git \
    iptables-dev \
    libavfilter-dev \
    libevent-dev \
    libpcap-dev \
    libxmlrpc-core-c3-dev \
    markdown \
    libjson-glib-dev \
    default-libmysqlclient-dev \
    libhiredis-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libavcodec-extra gperf \
    libspandsp-dev \
    libwebsockets-dev \
  && cd /usr/local/src \
  && git clone https://github.com/sipwise/rtpengine.git \
  && cd rtpengine/daemon \
  && git checkout ${RTPENGINE_VERSION} \
  && make && make install \
  && cp /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin/rtpengine \
  && rm -Rf /usr/local/src/rtpengine \
  && apt-get purge -y --quiet --force-yes --auto-remove \
    ca-certificates \
    gcc \
    g++ \
    make \
    build-essential \
    git \
    markdown \
  && rm -rf /var/lib/apt/* \
  && rm -rf /var/lib/dpkg/* \
  && rm -rf /var/lib/cache/* \
  && rm -Rf /var/log/* \
  && rm -Rf /usr/local/src/* \
  && rm -Rf /var/lib/apt/lists/*

VOLUME ["/tmp"]

EXPOSE 23000-32768/udp 8080/tcp

ENV HTTP_PORT=8080
ENV MIN_PORT=23000
ENV MAX_PORT=32768
ENV RECORDING_DIR=/tmp
ENV LOG_LEVEL=7
ENV RECORDING_METHOD=pcap
ENV DELETE_DELAY=0
ENV RECORDING_FORMAT=eth

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["rtpengine"]
