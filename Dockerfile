# # This Dockerfile will build an image that is configured
# # to run Fluentd with a Kinesis plug-in and the
# # provided configuration file.

FROM fluent/fluentd:v1.1-onbuild
RUN apk add --update --virtual .build-deps \
        sudo build-base ruby-dev \
        && sudo gem install \
          fluent-plugin-kinesis fluent-plugin-kubernetes_metadata_filter net-http-persistent \
        && sudo gem sources --clear-all \
        && apk del .build-deps \
        && rm -rf /var/cache/apk/* \
          /home/fluent/.gem/ruby/2.3.0/cache/*.gem