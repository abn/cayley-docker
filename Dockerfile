FROM fedora:latest
MAINTAINER Arun Neelicattu <arun.neelicattu@gmail.com>

ENV PACKAGE github.com/google/cayley
ENV COMMAND cmd/cayley

RUN dnf -y install golang git

ENV GOPATH /gopath

RUN mkdir -p ${GOPATH}

RUN CGO_ENABLED=0 go get -a -tags netgo -ldflags '-s' \
        --installsuffix cgo ${PACKAGE}/${COMMAND}

WORKDIR ${GOPATH}/bin
RUN mkdir assets data tmp
RUN mv \
    ${GOPATH}/src/${PACKAGE}/static \
    ${GOPATH}/src/${PACKAGE}/templates \
    ${GOPATH}/src/${PACKAGE}/docs \
    .

COPY Dockerfile.final /gopath/bin/Dockerfile

CMD docker build -t cayley /gopath/bin
