.PHONY:	build push

TAG = 0.1

build:
	docker build -t quay.io/repository/fluentd-kinesis:$(TAG) .

push:
	docker push quay.io/falkonry/fluentd-kinesis:$(TAG)
