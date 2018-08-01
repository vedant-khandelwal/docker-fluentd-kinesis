# # This Dockerfile will build an image that is configured
# # to run Fluentd with a Kinesis plug-in and the
# # provided configuration file.

FROM debian:stretch-slim

ENV FLUENTD_VERSION=1.2.0
ENV JEMALLOC_VERSION=4.4.0
ENV OJ_VERSION=3.3.10
ENV JSON_VERSION=2.1.0
ENV FLUENTD_SYSTEMD_PLUGIN=1.0.1

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    ruby \
  && buildDeps=" \
    make gcc g++ libc-dev \
    ruby-dev \
    wget bzip2 gnupg dirmngr \
    " \
  && apt-get install -y --no-install-recommends $buildDeps \
  && update-ca-certificates \
  && echo 'gem: --no-document' >> /etc/gemrc \
  && gem install oj -v $OJ_VERSION \
  && gem install json -v $JSON_VERSION \
  && gem install fluentd -v $FLUENTD_VERSION \
  && gem install fluent-plugin-kinesis fluent-plugin-kubernetes_metadata_filter net-http-persistent \
  && gem install fluent-plugin-systemd -v $FLUENTD_SYSTEMD_PLUGIN \
  && wget -O /tmp/jemalloc-${JEMALLOC_VERSION}.tar.bz2 https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2 \
  && cd /tmp && tar -xjf jemalloc-${JEMALLOC_VERSION}.tar.bz2 && cd jemalloc-${JEMALLOC_VERSION}/ \
  && ./configure && make \
  && mv lib/libjemalloc.so.2 /usr/lib \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN mkdir -p /fluentd/log /fluentd/etc /fluentd/plugins

COPY fluent.conf /fluentd/etc/

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"
ENV DUMB_INIT_SETSID 0

EXPOSE 24224 5140

CMD exec fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins $FLUENTD_OPT          