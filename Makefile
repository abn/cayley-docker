
ROOT		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILDER		:= local/builder

REPOSITORY	:= docker.io/alectolytic/cayley
VERSION		:= master

.PHONY: all build clean

all: build

build:
	@docker build -t $(BUILDER) $(ROOT)
	@docker run \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell which docker):$(shell which docker) \
		-it $(BUILDER)

push/$(VERSION):
	@docker tag -f $(REPOSITORY):latest $(REPOSITORY):$(VERSION)
	@docker push $(REPOSITORY):$(VERSION)

push/latest:
	@docker push $(REPOSITORY):latest

bumpversion:
	@sed -i s/'ENV VERSION .*$$'/'ENV VERSION $(VERSION)'/ $(ROOT)/Dockerfile
	@sed -ie s/'^\(VERSION\s*:=\s\).*$$'/'\1$(VERSION)'/ $(ROOT)/Makefile
	@git add $(ROOT)/Dockerfile $(ROOT)/Makefile
	@git commit -m "Update to $(VERSION)"

clean:
	@docker rmi -f $(BUILDER)
