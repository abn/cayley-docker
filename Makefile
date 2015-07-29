
ROOT		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILDER		:= local/builder

.PHONY: all build clean

all: build

build:
	@docker build -t $(BUILDER) $(ROOT)
	@docker run \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell which docker):$(shell which docker) \
		-it $(BUILDER)

clean:
	@docker rmi -f $(BUILDER)
