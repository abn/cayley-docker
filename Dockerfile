FROM fedora:latest
MAINTAINER Arun Neelicattu <arun.neelicattu@gmail.com>

RUN dnf -y upgrade

# install base requirements
RUN dnf -y install golang git hg

# prepare gopath
ENV GOPATH /go
ENV PATH /go/bin:${PATH}
RUN mkdir -p ${GOPATH}

ENV PACKAGE github.com/google/cayley
ENV VERSION 0.4.1
ENV GO_BUILD_TAGS netgo
ENV CGO_ENABLED 0

RUN go get github.com/tools/godep
RUN go get ${PACKAGE}

WORKDIR ${GOPATH}/src/${PACKAGE}
RUN git checkout -b v${VERSION} v${VERSION}

RUN godep restore

RUN GOPATH=`godep path`:${GOPATH} go build \
        -tags "${GO_BUILD_TAGS}" \
        -ldflags "-s -w -X ${PACKAGE}/version.Version ${VERSION}" \
        -v -a -installsuffix cgo \
        -o ./cayley \
        .

RUN rm -rf ./data/*
RUN mkdir tmp log

RUN rm -f ${PWD}/Dockerfile
COPY Dockerfile.final ./Dockerfile

COPY Dockerfile.final /gopath/bin/Dockerfile

CMD docker build -t alectolytic/cayley ${PWD}
