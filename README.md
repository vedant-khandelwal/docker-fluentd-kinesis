# Collecting Docker Log Files with Fluentd and Kinesis
This directory contains the source files needed to make a Docker image
that collects Docker container log files using [Fluentd](http://www.fluentd.org/)
and sends them to Kinesis Streams.
Required Environment vars:
  AWS_KEY_ID
  AWS_SECRET_KEY
  KINESIS_STREAM_NAME
  AWS_REGION